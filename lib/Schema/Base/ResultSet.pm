
package Schema::Base::ResultSet;
use strict;
use warnings;

use JSON::XS qw/to_json/;
use base qw/DBIx::Class::ResultSet/;

use Carp;

sub has_access{

	my ($self, $permission, $user, $alias) = @_;

	$user = $self->result_source->schema->user unless $user;
	$permission ||= "read";
## do necessary user validation  
	croak ("need to pass the user_id ") unless $user;
	croak ("No such column exists access_$permission") unless $self->result_source->has_column("access_$permission");

	$alias ||= $self->current_source_alias;

	return $self->search( { "$alias.access_$permission" => { 'like' , '%,' . $user . ',%'}} );

}
sub remove_access {

	my ($self, $permission, $user) = @_;
	
	croak ("need to pass the permission type") unless $permission;
	croak ("need to pass the user_id ") unless $user;
	croak ("No such column exists access_$permission") unless $self->result_source->has_column("access_$permission");

	## verify if the user exists and is active

	while(my $row = $self->next) {
		$row->remove_access($permission, $user);
		$row->update;
	}

	return 1;
}
sub grant_access {

	my ($self, $permission, $user) = @_;
	
	croak ("need to pass the permission type") unless $permission;
	croak ("need to pass the user_id ") unless $user;
	croak ("No such column exists access_$permission") unless $self->result_source->has_column("access_$permission");

	## verify if the user exists and is active

	while(my $row = $self->next) {
		$row->grant_access($permission, $user);
		$row->update;
	}

	return 1;
}


#sub serialize_to_perl {
#
#	my $self = shift;
#	my $rels = shift;

#	my @list = map {$_->serialize_to_perl($rels)} $self->all;

#	return \@list;
#}
sub serialize_to_perl {
    my $self = shift;
    my $rels = shift;
    #commenting out for testing
    my @list = map {$_->serialize_to_perl($rels)} $self->all;
    return \@list;
    #return [$self->all];
}
sub serialize_to_json{

	my $self = shift;
	my $json_str ;

	$json_str = to_json($self->serialize_to_perl(1) );

	return $json_str;

}

sub fetch {

	my $self = shift;
	my $id = shift;
	my $user = shift || $self->result_source->schema->user;
	
	croak("No valid user found") unless $user;	
	croak("Need primary key to find the object") unless $id;	

	#my $object = $self->find($id)->has_access("read", $user);
	my $attributes = {};

	#my $object = $self->find($id, $attributes);
	my $object = $self->has_access("read", $user)->find($id, $attributes);

	croak("user object not found") unless $object;	

	return $object;
}

sub fetch_new {

	my $self = shift;
	my $id = shift;
	my $user = shift;
	$user = $self->result_source->schema->user;

	croak("No valid user found") unless $user;	

	my $object = $self->new({});

    $object->status(1);
	$object->grant_access("read", $user);
	$object->grant_access("write", $user);

	$object->active(1);
	$object->log(1);

	return $object;
}

sub get_next_invoice_no {

	my $self = shift;

	return $self->recent->[0]->{'invoice_no'} + 1;
}

sub get_prev_invoice_date {

	my $self = shift;

	return $self->recent->[0]->{'invoice_date'} ;
}

sub purge {

	my $self = shift;

	#$self->is_deleted->delete;
    $self->delete;
}

sub is_valid {

	my $self = shift;
	my $alias = shift;

	$alias ||= $self->current_source_alias;
    
    $self;
	#$self->search( { "$alias.status" => { '!=' , 11 } });
}

sub is_deleted {
	
	my $self = shift;
	my $alias = shift;

	$alias ||= $self->current_source_alias;
	#return $self->search_bitfield( { "$alias.deleted" => 1 } );
	return $self;
}
sub look_for {
	
	my ($self, $search, $attributes) = @_;

    ## do necessary user validation  
	
	return $self->has_access->is_valid->search( $search, $attributes)->serialize_to_perl(1) ;

}


sub recent {

	my ($self, $limit, $search) = @_;

    $limit ||= 3;
	my $alias = $self->current_source_alias;

    return $self->look_for( $search, { order_by => { -desc => "$alias.created_on" }  ,rows => $limit }  );

}

1;
