use warnings;
use strict;
use Test::More;
use Data::Dumper;
use JSON::XS qw/encode_json/;


use Schema;

my $dbname = "t/etc/small.db";
my $schema = Schema->init_schema($dbname);

my $user = 1;

$schema->user($user);

my $author_rs = $schema->resultset("Author");

my $book_rs = $schema->resultset("Book");

## find all authors of a particular book 

#diag("default serialization");

my $recent_books = $book_rs->recent(5,'id')->serialize;;

is(scalar @$recent_books, 5, 'Found 5 records correctly');

my $authors = $recent_books->[0]->{authors};

#diag("using inbuilt ResultClass");

my $first_book = $recent_books->[0];

is($first_book->{id},20, "Found book id to be correct");

ok(!$first_book->{'created_on'}, "Base columns are not fetched by default");

## convert entire book hash along with authors
isnt(ref $recent_books->[0]->{'author_books'} , "ARRAY", "No relationships are fetched by default");

#diag("serialize with relationships");

$recent_books = $book_rs->recent->serialize( { include_relationships => 1 });

is(ref $recent_books->[0]->{'authors'} , "ARRAY", "relationships are fetched correctly");

ok(exists $recent_books->[0]->{'authors'}->[0]->{first_name}, "going deeper");

is(scalar(@{ $recent_books->[0]->{'authors'} }), 2, "Array has two elements");

#diag("serialize with relationships but fetch only primary key for relationships");

$recent_books = $book_rs->recent->serialize( { include_relationships => 1, only_keys => 1 });

is(ref $recent_books->[0]->{'authors'} , "ARRAY", "relationships are fetched correctly");

isnt(ref $recent_books->[0]->{'authors'}->[0], "HASH", "Not a Hash a reference");

#diag("serialize with arranged by primary key returned as hashref");

$recent_books = $book_rs->recent(3,'id')->serialize( { include_relationships => 1, index => 1});

is(ref $recent_books, "HASH" , "its a HASH");

is(keys %$recent_books, 3 , "Still got 3 books");

is(ref $recent_books->{20} , "HASH", "Found the first book");

is(ref $recent_books->{20}->{authors} , "HASH", "relationships are also a hash");

is(keys %{$recent_books->{20}->{authors}} , 2, "returned correct set of authors");

#diag("really insane");

$recent_books = $book_rs->recent->serialize( { include_relationships => 1,  include_base_columns => 1, 
												only_keys => 1, key => 'id' , indexed_by => '_id' });

#diag(Dumper($recent_books));
done_testing(14);

## default behaviour 

#diag(Dumper($authors->serialize ));
#
#
#default behaviour arranged by primary keys 
#diag(Dumper($authors->serialize( { index => 1} )));
#
#same thing but indexed via user specified column
#diag(Dumper($authors->serialize( { 'indexed_by' => '_id'  })));

# default and simple behaviour for include relationships, fetched everything
#diag(Dumper($authors->serialize( { 'include_relationships' => 1 } )));

# include only relationship links and not the complete result.
#diag(Dumper($authors->serialize( { 'include_relationships' => 1, only_keys => 1 } )));
#
#fetch same thing but via specific column links
#diag(Dumper($authors->serialize( { 'include_relationships' => 1, only_keys => 1 , key => '_id' } )));
#
#combination of relationships indexed
#diag(Dumper($authors->serialize( { 'include_relationships' => 1, index => 1 } )));
#
#Expanding the same combination with custom key
#diag(Dumper($authors->serialize( { 'include_relationships' => 1, indexed_by => '_id' } )));
#
#Further, including only relationship links
#diag(Dumper($authors->serialize( { 'include_relationships' => 1, indexed_by => '_id' , only_keys => 1, key => '_id' } )));

#diag(Dumper($book->serialize({'include_relationships'=> 1, 'index' => 1, 'only_keys' => 0})));
