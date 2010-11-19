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

	return $self->search_rs(undef, { join => [  'category' ] ,
	
									+select => [qw/ category._id/],

									+as => [qw/my_category_id/]
	} );
};

1;
