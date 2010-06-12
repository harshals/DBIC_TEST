package DBIx::Class::InflateColumn::CSV;
use Carp qw/croak confess/;

sub register_column {
    my $self = shift;
    my ($column, $info) = @_;
    
    $self->next::method(@_);
    
    return unless defined $info->{is_csv} and $info->{is_csv};
    
    
    $self->inflate_column(
        $column => {
	inflate => sub {
                my $val = shift;

	 	croak("value must be Scalar")
			unless ref $val ne 'ARRAY';
	 	croak("value $val must be CSV")
			unless $val =~ m/,/ ;

		my @values = grep { $_} map{ my $e = $_; $e =~ s/__COMMA__/,/g ; $e }  split(",", $val);
		
                return \@values;
            },
	    deflate => sub {
		my $val = shift;
		
	 	croak("value must be Array")
			unless ref $val eq 'ARRAY';
		
		## remove any commas
		my @values = map{ my $e = $_; $e =~ s/,/__COMMA__/g ; $e} grep { $_ }  @$val;		

                return "," . join( ",", @values) . ",";
            }
        }
    );

}

sub find_in_csv {
	my ($self, $col, $el ) = @_;

	return unless $el;

	$self->throw_exception("No such column $col to inflate") unless $self->has_column($col);

	$self->throw_exception("$col not a CSV column") unless $self->column_info($col)->{is_csv} ;
	
	my @result = grep {$_ eq $el } @{ $self->get_inflated_column($col) || [] };

	return scalar(@result);
}

sub add_to_csv {
	my ($self, $col, $el ) = @_;
	
	return unless $el;

	$self->throw_exception("No such column $col to inflate") unless $self->has_column($col);

	$self->throw_exception("$col not a CSV column") unless $self->column_info($col)->{is_csv} ;
	
	my $list = $self->get_inflated_column($col);

	push @$list, $el unless $self->find_in_csv($col, $el);

	$self->set_inflated_column($col => $list );
}
sub remove_from_csv {
	my ($self, $col, $el ) = @_;
	
	return unless $el;

	$self->throw_exception("No such column $col to inflate") unless $self->has_column($col);

	$self->throw_exception("$col not a CSV column") unless $self->column_info($col)->{is_csv} ;
	
	my $list = $self->get_inflated_column($col);

	$self->set_inflated_column(
		$col => [ grep { $_ ne $el } @$list]  );
}
1;

