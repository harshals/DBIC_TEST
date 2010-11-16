
package Schema::Base::ResultClass;
use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
#use base qw/Schema::Base::Result/;
extends qw/DBIx::Class::ResultClass::HashRefInflator/;

sub inflate_result {
    return $mk_hash->($_[2], $_[3]);
}

override 'inflate_result' => sub {
	
    return $mk_hash->($_[2], $_[3]);
};
