
package Schema::Base::ResultClass;
use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
use Storable qw/thaw/;
extends qw/DBIx::Class::ResultClass::HashRefInflator/;
;


# wrapper around original module to
# infalte frozen columns
around 'inflate_result' => sub {
	
	my $orig = shift;
	my $self = shift;
	my $unkown = shift;
	my ($data, $rel_ref) = @_;

	my $row = $self->$orig($unkown, $data, $rel_ref);

	my $inner_data = defined $row->{'data'} ? eval { thaw( $row->{'data'} ) }  || {} : {};
	$row = { %$row , %$inner_data };
	delete $row->{'data'};

	return $row;
};

1;
