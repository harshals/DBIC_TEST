package Schema::ResultSet::Book;

use strict;
use warnings;
use Moose;
use namespace::clean -except => 'meta';

extends qw/Schema::Base::ResultSet/;

override 'fetch_tree' => sub {

    my $self = shift;

	print STDERR "coming here";

#join => [ { 'author_books' => 'author' }, 'category' ] ,

	return $self->search_rs(undef, { join => [  'category' , { author_books=> 'author' }] ,
									
									include_columns => [qw/category.category author.first_name/],



	} );
};

1;
