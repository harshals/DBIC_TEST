
package Schema::Base::ResultClass;
use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
use Storable qw/thaw/;
extends qw/DBIx::Class::ResultClass::HashRefInflator/;


# wrapper around original module to
# infalte frozen columns
around 'inflate_result' => sub {
	
	my $orig = shift;
	my $self = shift;
	my $result_source = shift;
	my ($data, $rel_ref, $include_base_columns) = @_;

	my $row = $self->$orig($result_source, $data, $rel_ref);
	
	my $inner_data = defined $row->{'data'} ? eval { thaw( $row->{'data'} ) }  || {} : {};
	
	unless ($include_base_columns) {
	
		delete $row->{$_} foreach (qw/created_on updated_on status active access_read access_write/) ;
	};

	$row = { %$row , %$inner_data };
		
	delete $row->{'data'};

	return $row;
};

1;
