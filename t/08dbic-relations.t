use warnings;
use strict;
use Test::More tests => 13;
use Data::Dumper;
use JSON::XS qw/encode_json/;


use Schema;

my $schema = Schema->init_schema("t/etc/large.db");

my $user = 1;

$schema->user($user);

my $author_rs = $schema->resultset("Author");

my $book_rs = $schema->resultset("Book");

my $category_rs = $schema->resultset("Category");

my $affiliate_rs = $schema->resultset("Affiliate");

my $author_book_rs = $schema->resultset("AuthorBooks");

my $author_affiliate_rs = $schema->resultset("AuthorAffiliations");

my $author_category_rs = $schema->resultset("AuthorCategories");

is($book_rs->count,500, "found 500 books");

## find all authors of a particular book 

my $book = $book_rs->search_rs( { -and => [ { 'me.id' => {'>=', 3} } , { 'me.id' => {'<=', 4}   } ] }, 
								{ 
									prefetch => { author_books => 'author'  }  ,
									order_by => { -asc => 'me.id' }
								});

my $authors = $book->first->authors;

#diag("using inbuilt ResultClass");

my $first_book = $book->next;

is($book->count, 2, 'Found 8 records correctly');

is($first_book->id,4, "Found book id to be correct");

#diag($first_book->subtitle);

is($first_book->subtitle, 'The Complete Language ANSI/ISO Compliant, Third Edition', "Found Frzoen column");

is($authors->count,5 , 'This book has 5 authors');

## getting stuck here
#diag(Dumper($authors->serialize));

is($authors->first->first_name, 'Connor', "Found correct fist name ");

is($authors->first->country, 'China', "Found correct frozen column ");

## convert entire book hash along with authors
my $list =  $book->serialize ;

#diag(Dumper($list));

is(scalar(@$list), 2, "Hash has two elements");

is(ref $list->[0]->{'author_books'} , "ARRAY", "First element is hash reference");

is($list->[0]->{'author_books'}->[0]->{'book_id'}, $list->[0]->{id}, "1st level relationship maintained");

ok(exists $list->[0]->{'author_books'}->[0]->{'author'}->{first_name}, "going deeper");

$list = $authors->serialize;

diag("\nBooks->Authors isnt a simple array but instead retains original resultclass");

is(scalar(@$list), 5, "Array has five elements");

is(ref $list->[0], "Schema::Result::Author", "Still a blessed refernce !!");

diag("Checking for list with relationships");

$authors = $author_rs->search_rs( { -and => [ { 'me.id' => {'>=', 3} } , { 'me.id' => {'<=', 4}   } ] }  );

diag(Dumper($authors->serialize( { 'include_relationships' => 1 , 'only_primary_keys' => 1} )));

#diag($authors->to_json({ 'skip_relationships' => 0 , 'only_links' => 1}));



