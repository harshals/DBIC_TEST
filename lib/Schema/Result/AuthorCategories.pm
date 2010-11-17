package Schema::Result::AuthorCategories;

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
#use base qw/Schema::Base::Result/;
extends qw/Schema::Base::Result/;

__PACKAGE__->table("author_category");
__PACKAGE__->add_columns(

	qw/author_id category_id/
);


__PACKAGE__->set_primary_key("author_id");
__PACKAGE__->set_primary_key("category_id");

__PACKAGE__->belongs_to(
  "author",
  "Schema::Result::Author",
  { "foreign.id" => "self.author_id" },
);

__PACKAGE__->belongs_to(
  "category",
  "Schema::Result::Category",
  { "foreign.id" => "self.category_id" },
);



# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-13 21:11:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:obZUGgvkve3e6mzPk8GEEg

sub extra_columns {
    
    my $self = shift;

    return qw//;
};
# You can replace this text with custom content, and it will be preserved on regeneration


__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
