#
#===============================================================================
#
#         FILE:  05-deploy.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  11/30/2010 17:04:54 IST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 7;

BEGIN { use_ok 'Schema' }

my $dbname = "library";

#diag("Remove old database if it exists");

`rm -f $dbname` if -f $dbname;

my $schema = Schema->init_schema($dbname, "mysql", "root");

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


