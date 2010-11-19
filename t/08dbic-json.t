use warnings;
use strict;
use Test::More 'no_plan';
use Data::Dumper;

BEGIN { use_ok 'Schema' }

my $schema = Schema->init_schema("t/etc/small.db");

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

my $author_rs = $schema->resultset("Author");

my $book_rs = $schema->resultset("Book");

my $category_rs = $schema->resultset("Category");

my $affiliate_rs = $schema->resultset("Affiliate");

my $book1_rs = $book_rs->search_rs( { 'id' => 3 } );

my $authors = $book1_rs->single->authors;

#$book1_rs->result_class('Schema::Base::ResultClass');
#$authors->result_class('Schema::Base::ResultClass');

my $book_hash = $book1_rs->serialize->[0];

#diag(Dumper($book_hash));

is($book_hash->{subtitle} , "Practical Solutions", "Frozen Column Correctly infalted");

my $authors_list =  $authors->serialize;

is(scalar(@$authors_list), 5, "Found correct set of authors");

my $first_author = $book_rs->find(3)->authors->first;

diag(Dumper($authors_list));
is(scalar(@$authors_list), 5, "Found correct set of authors");
