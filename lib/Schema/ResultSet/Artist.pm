package Schema::ResultSet::Artist;

use strict;
use warnings;
use Moose;
use namespace::clean -except => 'meta';

#use base qw/DBIx::Class::ResultSet/;
extends qw/Schema::Base::ResultSet/;

1;
