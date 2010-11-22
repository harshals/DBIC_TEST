package Schema::ResultSet::Book;

use strict;
use warnings;
use Moose;
use namespace::clean -except => 'meta';
use Carp;

extends qw/Schema::Base::ResultSet/;

override 'prefetch_related' => sub {

    my $self = shift;
	my $relationships = shift || [  'category' , { author_books=> 'author' }];

	croak "relatonships need to be an array ref " unless ref $relationships eq 'ARRAY';

	return $self->search_rs(undef, { prefetch =>   $relationships ,
									
									#include_columns => [qw/category.category author.first_name/],
	} );
};



1;
