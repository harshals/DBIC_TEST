use warnings;
use strict;
use Test::More tests => 12;

BEGIN { use_ok 'Schema' }


#diag("Remove old database if it exists");

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

like($dbtype,qr/SQLite|mysql|PostgreSQL/, "Found Correct DB Type");

SKIP: {
	skip "Only Mysql or PostgresSQL specific test", 1 if $dbtype eq 'SQLite';
	ok($dbname && $username && $password && $host, "Found correct DSN");
}

SKIP: {
	skip "Only SQLite specific test", 1 unless $dbtype eq 'SQLite';

	`rm -f $dbname` if -f $dbname;
	ok(! (-f $dbname), "No existing database");
}

my $schema = Schema->init_schema($dbname, $dbtype, $username, $password , $host);

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

SKIP: {
	skip "Only SQLite specific test", 1 unless $dbtype eq 'SQLite';

	$schema->create_ddl_dir;
	`sqlite3 $dbname < Schema-1.x-$dbtype.sql`;
	ok(-f $dbname, "Deployed $dbname database");
}
SKIP: {
	skip "Only Mysql or PostgresSQL specific test", 1 if $dbtype eq 'SQLite';

	$schema->deploy;

	isa_ok($schema->storage, "DBIx::Class::Storage", "Deployed $dbname database");
}

is($schema->user, 1, "Schema user set to 1 ");

my $author_rs = $schema->resultset("Author");

isa_ok($author_rs, 'Schema::ResultSet::Author');

my $book_rs = $schema->resultset("Book");

isa_ok($book_rs, 'Schema::Base::ResultSet');

my $category_rs = $schema->resultset("Category");

isa_ok($category_rs, 'Schema::Base::ResultSet');

my $affiliate_rs = $schema->resultset("Affiliate");

isa_ok($affiliate_rs, 'Schema::Base::ResultSet');


