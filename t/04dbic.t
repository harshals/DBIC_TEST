use warnings;
use strict;
use Test::More tests => 13;

BEGIN { use_ok 'Schema' }

my $schema = Schema->init_schema();

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

ok($schema->user, "Schema User is set");

my $artist_rs = $schema->resultset("Artist");

isa_ok($artist_rs, 'Schema::ResultSet::Artist');

ok(my $artist = $artist_rs->find(1) , "Found first Artist");

is($artist->id, 1, "Got 1st id");

is($artist->country, "Ghana", "Frozen Columns working fine");

ok($artist->country("India"), "Changing country to ghana");

ok(!$artist->log(0), "Turning off the log");

$artist->update;

ok(my $artist2 = $artist_rs->find(1) , "Found first Artist Again ");

is($artist2->country, "India", "Found the new country ");

ok($artist2->active, "Object is active");

ok(!$artist2->deleted, "Object is not deleted");

diag($artist->serialize_to_json);

1;
