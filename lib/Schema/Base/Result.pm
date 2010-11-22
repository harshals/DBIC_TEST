package Schema::Base::Result;

use strict;
use warnings;
use Moose;
use namespace::clean -except => 'meta';
use Carp qw/croak confess/;

use JSON::XS qw/encode_json /;
#use base qw/DBIx::Class/;
extends qw/DBIx::Class/;

__PACKAGE__->load_components(qw/FrozenColumns UUIDColumns InflateColumn::CSV TimeStamp  Core/);


sub add_base_columns {

    my $self = shift;

	my $source = $self->result_source_instance;

    $self->add_columns(

		"id", { data_type => "INTEGER", is_nullable => 0, is_base => 1},
		
		"_id", { data_type => "TEXT", is_nullable => 0, is_base => 1},
		
		"created_on", { data_type => "DATETIME" ,set_on_create => 1 , is_base => 1}, 

		"updated_on" , { data_type => "DATETIME" ,set_on_create => 1, set_on_update => 1, is_base => 1},
	
		"access_read" , { data_type => "TEXT" , is_csv => 1, is_base => 1},

		"access_write" , { data_type => "TEXT" , is_csv => 1, is_base => 1},

		"active", { data_type => "INTEGER", is_base => 1 , is_nullable => 0},

		"status", { data_type => "TEXT" , is_csv => 1, is_base => 1 , is_nullable => 0},
		
        "data", { data_type => "VARCHAR", is_nullable => 1}
    );
	
	
    $self->add_frozen_columns(
        data => $self->extra_columns 
    );
	
	$self->uuid_columns('_id');
}

sub extra_columns {
    
    return ();
}

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-13 21:11:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IEbbWr9Imbum+8sUaLrAAg

=pod
after 'table' => sub {

	my $class = shift;
	
    my $source = $class->result_source_instance;
	if ($source->resultset_class ne 'Schema::Base::ResultSet') {
		$source->resultset_class("Schema::Base::ResultSet");
	}
};
=cut
sub has_access {

	my ($self, $permission, $user) = @_;

	$user = $self->result_source->schema->user unless $user;
	$permission ||= "read";

	croak ("need to pass the permission type") unless $permission;
	croak ("need to pass the user_id ") unless $user;
	croak ("No such column exists access_$permission") unless $self->has_column("access_$permission");
	
	## verify if the user exists and is active
	
	$self->find_in_csv("access_$permission", $user);

}

sub remove_access {

	my ($self, $permission, $user) = @_;
	
	croak ("need to pass the permission type") unless $permission;
	croak ("need to pass the user_id ") unless $user;
	croak ("No such column exists access_$permission") unless $self->has_column("access_$permission");

	## verify if the user exists and is active
	
	$self->remove_from_csv("access_$permission", $user);

}

sub grant_access {

	my ($self, $permission, $user) = @_;
	
	croak ("need to pass the permission type") unless $permission;
	croak ("need to pass the user_id ") unless $user;
	croak ("No such column exists access_$permission") unless $self->has_column("access_$permission");

	## verify if the user exists and is active
	
	$self->add_to_csv("access_$permission", $user);

}
sub has_status {

	my ($self, $status) = @_;
	
	croak ("You do not have requisite permission") unless $self->has_access("write");
	croak ("Unkown status type") unless $status =~ m/active|delete|dirty/;

	## verify if the user exists and is active
	
	$self->find_in_csv("status", $status);
}
sub remove_status {

	my ($self, $status) = @_;
	
	croak ("You do not have requisite permission") unless $self->has_access("write");
	croak ("Unkown status type") unless $status =~ m/active|delete|dirty/;

	## verify if the user exists and is active
	
	$self->remove_from_csv("status", $status);
}
sub set_status {

	my ($self, $status) = @_;
	
	croak ("You do not have requisite permission") unless $self->has_access("write");
	croak ("Unkown status type") unless $status =~ m/active|delete|dirty/;

	## verify if the user exists and is active
	
	$self->add_to_csv("status", $status);

}
sub get_expanded_columns {

	my $self = shift;
	my %object = $self->get_columns;
	
	delete $object{'data'};

	## thaw the frozen columns
    unless ($self->in_storage) {
		
		%object = (%object, $self->frozen_columns);
    }
	
	return \%object;
}

sub serialize {

	my $self = shift;
	my $options = shift || { 'skip_relations' => 0 , 'only_links' => 0 };
	
	my $object = $self->get_expanded_columns ;

	my $relationships =  inner() || {} ;

	return { %$object , %$relationships };
}

	
sub serialize_to_json{

	my $self = shift;
	my $data = shift;
	my $json_str ;

	## to process relationships upto level 1
	$data = $self->serialize_to_perl(1) unless ref $data =~ /HASH/;

	use Data::Dumper;

	croak Dumper($data);

	$json_str = encode_json($data);

	#return (get_error_string) ? get_error_string : $json_str;
	return $json_str;
}

sub save {

	my $self = shift;
	my $data = shift;

	my $user = $self->result_source->schema->user ;

	croak(" You do not have write permissions") 
		unless $self->has_access("write", $user);

	#croak(" Object is dirty . Can't do much") 
	#	if $self->is_dirty;

	foreach my $column ($self->columns ) {

		next if $self->result_source->column_info($column)->{"is_base"};
		$self->set_column($column, $data->{$column}) if exists $data->{$column};
	}
	my %extra_data;
	foreach my $column ($self->frozen_columns_list){
	#foreach my $column ($self->extra_columns ) {
		
		#$extra_data{$column} = $data->{$column} if exists $data->{$column};
		$self->set_column( $column, $data->{$column}) if exists $data->{$column};
		
	}
	#$self->data(\%extra_data);

    ($self->id) ? $self->update : $self->insert;
	#$self->insert_or_update;
	
}

sub remove {

	my $self = shift;
	my $user = shift ;

	croak(" You do not have write permissions") 
		unless $self->has_access("write", $user);

	$self->active(0);

	$self->insert_or_update;
}

sub purge {

	my $self = shift;

	#$self->dirty(1);
	$self->delete if $self->deleted;
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
