package DBIC_TEST::Base::Controller;
#
#===============================================================================
#
#         FILE:  Base.pm
#
#  DESCRIPTION:  Base controllers for catalyst
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Harshal Shah (Hs), <harshal.shah@gmail.com>
#      COMPANY:  MK Software
#      VERSION:  1.0
#      CREATED:  09/07/2009 15:48:59 IST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use JSON::XS qw/encode_json/;


use base "Catalyst::Controller";

sub get : Chained('base') : PathPart("get") : Args(1) {

	my ($self, $c, $id) = @_;

	my $model = $c->stash->{"model"};
	
	my $obj = ($id eq 'new') ? $model->fetch_new : $model->fetch($id);

	$c->stash->{"template"} =  $c->stash->{"template_prefix"} . "_form.tt" ;
	$c->stash->{ $c->stash->{'result_key'} } = $obj->serialize_to_perl(1);

}

sub delete: Chained('base') : PathPart("delete") : Args(1) {

	my ($self, $c, $id) = @_;

	my $model = $c->stash->{"model"};
	
	my $obj =  $model->fetch($id);

	my $status = $obj->remove;
	
	my $return_data = { message => ($status) ? "Deleted Successfully" : "Unable to delete",
						error => (!$status) ? "Unable to delete" : "",
						metadata => $obj->serialize_to_perl
						} ;
        
	$c->response->body(encode_json($return_data));
	$c->response->content_type("Application/x-json");


}

sub put: Chained('base') : PathPart("put") : Args(0) {

	my ($self, $c) = @_;

	my $model = $c->stash->{"model"};
	
	my $req_data =   $c->req->params  ;

	my $obj = ($req_data->{'id'}) ? $model->fetch($req_data->{'id'}) : $model->fetch_new ;

	$obj->save($req_data);
	
    if ($req_data->{is_ajax}) {
        
        my $return_data = { message => "Saved Successfully" ,
                           result =>  {
                           value => $obj->id,
                           text => ($c->stash->{template_prefix} =~ m/modifier/) ? $obj->cenvat : $obj->id,
						   metadata => $obj->serialize_to_perl
                           }
        } ;
        
        $c->response->body(encode_json($return_data));
        $c->response->content_type("Application/x-json");

    } else {

        $c->stash->{"template"} =  $c->stash->{template_prefix} . "_form.tt";
        $c->stash->{ $c->stash->{result_key} } = $obj->serialize_to_perl;
        $c->stash("message", "Saved Successfully");
        $c->forward("get", [ $obj->id ]);
    }

}


sub list : Chained('search') : PathPart("search") : Args(0) {

	my ($self, $c) = @_;

	my $model = $c->stash->{"model"};
	
	my $search =   $c->stash->{'search'};
	my $attributes =   $c->stash->{'attributes'};

    $c->stash->{ $c->stash->{result_key} . "_rs" } =  $model->look_for($search, $attributes) ;

    $c->stash->{"template"} =  $c->stash->{template_prefix} . "_list.tt";

}
1;
