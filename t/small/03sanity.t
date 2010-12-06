use warnings;
use strict;
use Test::More tests => 7;

BEGIN { use_ok 'Schema' }

my %args = ( @ARGV );
my $size = $args{"size"}  || "small";
my $dbname =  $args{"dbname"} || "t/etc/" . $size . ".db";
my $dbtype = $args{"dbtype"} || "SQLite";
my $password = $args{"p"};
my $username = $args{"u"};
my $host = $args{"h"};

##auto correct db types

$dbtype = "SQLite" if $dbtype =~ /sqlite/i;
$dbtype = "mysql" if $dbtype =~ /mysql/i;
$dbtype = "PostgreSQL" if $dbtype =~ /pg|postgre/i;



my $schema = Schema->init_schema($dbname, $dbtype, $username, $password , $host);

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

is($schema->user, 1, "Schema user set to 1 ");

my $author_rs = $schema->resultset("Author");

isa_ok($author_rs, 'Schema::ResultSet::Author');

my $book_rs = $schema->resultset("Book");

isa_ok($book_rs, 'Schema::Base::ResultSet');

my $category_rs = $schema->resultset("Category");

isa_ok($category_rs, 'Schema::Base::ResultSet');

my $affiliate_rs = $schema->resultset("Affiliate");

isa_ok($affiliate_rs, 'Schema::Base::ResultSet');


