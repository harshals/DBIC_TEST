package Schema::Result::Artist;

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
#use base qw/Schema::Base::Result/;
extends qw/Schema::Base::Result/;

__PACKAGE__->table("artist");
__PACKAGE__->add_columns(

	qw/first_name last_name/
);

__PACKAGE__->add_base_columns;

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint([ qw/first_name/ ]);


__PACKAGE__->has_many(
  "cds",
  "Schema::Result::Cd",
  { "foreign.artist_id" => "self.id" },
);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-13 21:11:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:obZUGgvkve3e6mzPk8GEEg
sub extra_columns {
    
    my $self = shift;

    return qw/dob address_1 address_2 city state zip country summary/;
};

# You can replace this text with custom content, and it will be preserved on regeneration


__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
