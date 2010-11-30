use warnings;
use strict;
use Test::More tests => 7;

BEGIN { use_ok 'Schema' }

my $dbname = "t/etc/small.db";

#diag("Remove old database if it exists");

`rm -f $dbname` if -f $dbname;

my $schema = Schema->init_schema($dbname);

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

$schema->deploy;

is($schema->user, 1, "Schema user set to 1 ");

my $author_rs = $schema->resultset("Author");

isa_ok($author_rs, 'Schema::ResultSet::Author');

my $book_rs = $schema->resultset("Book");

isa_ok($book_rs, 'Schema::Base::ResultSet');

my $category_rs = $schema->resultset("Category");

isa_ok($category_rs, 'Schema::Base::ResultSet');

my $affiliate_rs = $schema->resultset("Affiliate");

isa_ok($affiliate_rs, 'Schema::Base::ResultSet');


