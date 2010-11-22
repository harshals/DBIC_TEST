use warnings;
use strict;
use Test::More 'no_plan';
use Text::CSV::Slurp;
use Data::Dumper;
use Schema;

my $schema = Schema->init_schema("populate.db");

my $user = 1;

$schema->user($user);

$schema->deploy;

my $filename = "t/etc/data.csv";

ok(-f $filename, "Data filename found");

my $data = Text::CSV::Slurp->load(file => $filename  );

my $author_rs = $schema->resultset("Author");

my $book_rs = $schema->resultset("Book");

my $category_rs = $schema->resultset("Category");

my $affiliate_rs = $schema->resultset("Affiliate");

my $author_book_rs = $schema->resultset("AuthorBooks");

my $author_affiliate_rs = $schema->resultset("AuthorAffiliations");

my $author_category_rs = $schema->resultset("AuthorCategories");

my %base = ( active => 1, access_read => ",$user," , access_write => ",$user,", status => ",active," , data => '');

my $total_rows = scalar(@$data);


## override $total_rows
#$total_rows = 10;
diag("inserting $total_rows rows just for kicks");

foreach my $row  (splice( @$data, 0, $total_rows)) {
	
	next unless $row->{ISBN};

	my ($category,$book, $category_id);

	$category = $category_rs->find_or_create({ category => $row->{'Discipline'} , %base}, { key => 'category_category' }) if $row->{Discipline};
	
	$category_id = (defined $category ) ? $category->id : ''; 

	$book = $book_rs->find_or_create( {
		isbn => $row->{ISBN},
		classification => $row->{Classification},
		price => $row->{Price},
		title => $row->{Title},
		publish_date => $row->{PubDate},
		publish_year => $row->{PrintYear},
		subtitle => $row->{Subtitle},
		description => $row->{Description},
		toc => $row->{TOC},
		category_id => $category_id,
		%base
	} , { key => 'book_isbn' }) ;

	foreach my $author_id (1..5) {
		
		next unless $row->{"AuthorFirst$author_id"};

		my ($author, $affiliate );

		$affiliate = $affiliate_rs->find_or_create( { affiliate => $row->{ "AuthorAffiliation$author_id" }, %base } , { key => 'affiliate_affiliate' } )
						if $row->{ "AuthorAffiliation$author_id" };

		$author = $author_rs->find_or_create({
			
			first_name => $row->{ "AuthorFirst$author_id" },
			last_name => $row->{ "AuthorLast$author_id" },
			review => $row->{Reviews},
			country => $row->{AuthorCountry},
			url => $row->{ "AuthorURL$author_id" },
			%base
		}, { key => 'author_first_name_last_name' } );

		$author_affiliate_rs->find_or_create( { author_id => $author->id, affiliate_id => $affiliate->id } )
				if ($author && $affiliate );
		
		$author_book_rs->find_or_create( { author_id => $author->id, book_id => $book->id } );
		
		$author_category_rs->find_or_create( { author_id => $author->id, category_id => $category->id } )
				if ($author && $category);

	}

}


is($book_rs->count, $total_rows, "Found $total_rows books");
1;
