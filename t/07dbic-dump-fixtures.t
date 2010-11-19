#
#===============================================================================
#
#         FILE:  07dbic-dump-fixtures.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  11/19/2010 12:05:59 IST
#     REVISION:  ---
#===============================================================================


use warnings;
use strict;
use Test::More tests => 3;

use DBIx::Class::Fixtures;

BEGIN { use_ok 'Schema' }

my $schema = Schema->init_schema("t/etc/large.db");

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

ok($schema->user, "Schema User is set");

my $fixtures = DBIx::Class::Fixtures->new({ 
     config_dir => 't/etc' 
});

$fixtures->dump({
   config => 'set_config.json',
   schema => $schema,
   directory => 't/etc/fixtures'
});

