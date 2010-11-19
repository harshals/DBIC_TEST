use warnings;
use strict;
use Test::More tests => 7;
use JSON::XS qw/encode_json/;

use Schema;

my $schema = Schema->init_schema("t/etc/large.db");

my $user = 1;

$schema->user($user);

foreach my $source ($schema->sources) {
	
	my $rs = $schema->resultset($source);	
	my $table = $rs->result_source->from;

	my $json = encode_json( $rs->serialize );
	
	my $file = "t/etc/json/$table.json";

	open (FILE, ">$file") || die "file cannot be open";

	print FILE $json	;

	close FILE;

}

=pod

=cut
