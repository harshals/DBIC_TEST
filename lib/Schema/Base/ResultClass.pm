
package Schema::Base::ResultClass;
use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
#use base qw/Schema::Base::Result/;
extends qw/DBIx::Class::ResultClass::HashRefInflator/;

around 'inflate_result' => sub {
	
	my $orig = shift;
	my $self = shift;

    return $self->$orig(@_);
};

1;
