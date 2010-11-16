use warnings;
use strict;
use Test::More tests => 4;
use Data::Dumper;

BEGIN { use_ok 'Schema' }

my $schema = Schema->init_schema();

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

ok($schema->user, "Schema User is set");

my $artist_rs = $schema->resultset("Artist")->has_access("read",1);

$artist_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

ok(my $artist = $artist_rs->find(1, {prefetch => [ qw/cds/  ]}) , "Found first Artist");
#ok(my $artist = $artist_rs->has_access("read")->find(1, {prefetch => [ qw/cds/  ]}) , "Found first Artist");

#$artist->grant_access("read", 2);

#is($artist->country, "India", "Frozen Columns working fine");

diag(Dumper($artist));
