use warnings;
use strict;
use Test::More 'no_plan';
use Text::CSV::Slurp;

use Schema;

my $schema = Schema->init_schema("large.db");

my $user = 1;

$schema->user($user);

my $author_rs = $schema->resultset("Author");

my $book_rs = $schema->resultset("Book");

my $category_rs = $schema->resultset("Category");

my $affiliate_rs = $schema->resultset("Affiliate");

my $author_book_rs = $schema->resultset("AuthorBooks");

my $author_affiliate_rs = $schema->resultset("AuthorAffiliations");

my $author_category_rs = $schema->resultset("AuthorCategories");


## find all authors of a particular book 

use Data::Dumper;

my $first_book = $book_rs->search_rs( { id => 1 } , { prefetch => [qw/authors/] });

#$first_book->result_class("Schema::Base::ResultClass");

diag( Dumper($first_book->all) );

1;
