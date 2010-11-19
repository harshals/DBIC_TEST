use warnings;
use strict;
use Test::More tests => 7;
use Text::CSV::Slurp;

use Schema;

my $schema = Schema->init_schema("t/etc/small.db");

my $user = 1;

$schema->user($user);

foreach my $source ($schema->sources) {
	
	my $rs = $schema->resultset($source);	
	my $table = $rs->result_source->from;

	my $csv  = Text::CSV::Slurp->create( input => $rs->serialize );
	
	my $file = "t/etc/csv/$table.csv";

	open (FILE, ">$file") || die "file cannot be open";

	print FILE $csv	;

	close FILE;

}

=pod

=cut
