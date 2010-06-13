use warnings;
use strict;
use Test::More tests => 5;

BEGIN { use_ok 'Schema' }

my $schema = Schema->init_schema();

isa_ok($schema, 'DBIx::Class::Schema', "Schema initialised properly");

$schema->user(1);

ok($schema->user, "Schema User is set");

my $artist = $schema->resultset("Artist");

my $source = $artist->result_source;

$source->resultset_class("Schema::ResultSet::Artist");

isa_ok($artist, 'Schema::ResultSet::Artist');

is($artist->find(1)->id, 1, "Got 1st id");
