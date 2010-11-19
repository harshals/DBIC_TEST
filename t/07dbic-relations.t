use warnings;
use strict;
use Test::More tests => 7;
use Data::Dumper;
use Storable qw/thaw/;
use JSON::XS qw/encode_json/;


use Schema;

my $schema = Schema->init_schema("t/etc/small.db");

my $user = 1;

$schema->user($user);

my $author_rs = $schema->resultset("Author");

my $book_rs = $schema->resultset("Book");

my $category_rs = $schema->resultset("Category");

my $affiliate_rs = $schema->resultset("Affiliate");

my $author_book_rs = $schema->resultset("AuthorBooks");

my $author_affiliate_rs = $schema->resultset("AuthorAffiliations");

my $author_category_rs = $schema->resultset("AuthorCategories");

is($book_rs->count, 10, "found 500 books");

## find all authors of a particular book 

my $book = $book_rs->search_rs( { id => 3 } );

my $authors = $book->single->authors;

diag("using inbuilt ResultClass");

is($book->single->id,3, "Found book id to be correct");

is($book->single->subtitle, 'Practical Solutions', "Found Frzoen column");

is($authors->count,5 , 'This book has 5 authors');

is($authors->first->first_name, 'Connor', "Found correct fist name ");

is($authors->first->country, 'China', "Found correct frozen column ");


#$book->result_class("DBIx::Class::ResultClass::HashRefInflator");
$book->result_class("Schema::Base::ResultClass");

$authors->result_class("Schema::Base::ResultClass");

my $single_book = $book->single;

#diag(Dumper($single_book));

#is($single_book->{id},3, "Found book id to be correct");

#is($single_book->{data}, 'Practical Solutions in frozen columns');

diag(encode_json([$authors->all]));

