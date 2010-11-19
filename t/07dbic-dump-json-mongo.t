use warnings;
use strict;
use Test::More tests => 7;
use JSON::XS qw/encode_json/;
use Data::Dumper;
use Schema;

my $schema = Schema->init_schema("t/etc/small.db");

my $user = 1;

$schema->user($user);

foreach my $source ($schema->sources) {
	
	my $rs = $schema->resultset($source);	
	my $table = $rs->result_source->from;

	my $json;

	my $list = $rs->fetch_tree->serialize;

	diag(Dumper($list)) if $table eq 'book';

	foreach my $row  ( @$list ) {
		
		$json .= encode_json( $row ) . "\n";
	}
	
	my $file = "t/etc/json/$table.mongo.json";

	open (FILE, ">$file") || die "file cannot be open";

	print FILE $json	;

	close FILE;

}

=pod

=cut
