
package Schema::Base::ResultSet;
use strict;
use warnings;

use JSON::XS qw/encode_json/;
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

sub prefetch_related {
	
	my $self = shift;

	return $self;
}

sub related_links {

	my $self = shift;

	return $self;
}


sub to_json{

	my $self = shift;
	my $json_str ;

	$json_str = encode_json($self->serialize);

	return $json_str;

}

sub fetch {

	my $self = shift;
	my $id = shift;
	my $user = $self->result_source->schema->user;
	
	croak("No valid user found") unless $user;	
	croak("Need primary key to find the object") unless $id;	

	my $attributes = {};

	my $object = $self->is_valid->has_access("read", $user)->find($id, $attributes);

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

    $object->active(1);
	$object->grant_access("read", $user);
	$object->grant_access("write", $user);

	$object->set_status("active");

	return $object;
}



sub purge {

	my $self = shift;

    $self->delete;
}

sub is_valid {

	my $self = shift;

 	## do necessary user validation  
	
	my $alias ||= $self->current_source_alias;
    
	$self->search_rs( { "$alias.active" => 1 });
}

sub is_deleted {
	
	my $self = shift;
	my $alias = shift;

	$alias ||= $self->current_source_alias;

	return $self->search_rs( { "$alias.active" => 0, "$alias.status" => { 'like' , '%,' . 'deleted' . ',%'} } );
}
sub look_for {
	
	my ($self, $search, $attributes) = @_;

    ## do necessary user validation  
	
	return $self->has_access->is_valid->search_rs( $search, $attributes);
}

sub serialize {

	my ($self ) = @_;

	$self->result_class("Schema::Base::ResultClass");

	return [ $self->all ];
}

sub recent {

	my ($self, $limit ) = @_;

    $limit ||= 3;
	my $alias = $self->current_source_alias;

    return $self->search_rs( undef, { order_by => { -desc => "$alias.created_on" }  ,rows => $limit }  );

}

1;
