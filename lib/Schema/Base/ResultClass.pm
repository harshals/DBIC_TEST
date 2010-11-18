
package Schema::Base::ResultClass;
use strict;
use warnings;

use Data::Dumper;
use Moose;
use namespace::clean -except => 'meta';
#use base qw/Schema::Base::Result/;
use Storable qw/thaw/;
extends qw/DBIx::Class::ResultClass::HashRefInflator/;

my $mk_hash;
$mk_hash = sub {
	
	## $_[0] is the main hashref
	#$_[1] is the relationship hashref

    if (ref $_[0] eq 'ARRAY') {     # multi relationship
        return [ map { $mk_hash->(@$_) || () } (@_) ];
    }
    else {

		## thawing the storable if there in data key
		my $inner_data = defined $_[0]->{'data'} ? eval { thaw( $_[0]->{'data'} ) }  || {} : {};

        my $hash = {
            # the main hash could be an undef if we are processing a skipped-over join
            $_[0] ? %{$_[0]} : (),
			
			%{ $inner_data } ,

            # the second arg is a hash of arrays for each prefetched relation
            map
                { $_ => $mk_hash->( @{$_[1]->{$_}} ) }
                ( $_[1] ? (keys %{$_[1]}) : () )
        };
		
		# remove the data key
		delete $hash->{'data'} if exists $hash->{'data'} ;
        # if there is at least one defined column consider the resultset real
        # (and not an emtpy has_many rel containing one empty hashref)
        # an empty arrayref is an empty multi-sub-prefetch - don't consider
        # those either
        for (values %$hash) {
            if (ref $_ eq 'ARRAY') {
              return $hash if @$_;
            }
            elsif (defined $_) {
              return $hash;
            }
        }

        return undef;
    }
};


sub inflate_result {
#override 'inflate_result' => sub {
	
	my $self = shift;
	my $unkown = shift;
	my ($data, $rel_ref) = @_;

	#print STDERR "Calling " . Dumper($data);

    return $mk_hash->($data, $rel_ref);
    #return $self->$orig(@_);
};

1;
