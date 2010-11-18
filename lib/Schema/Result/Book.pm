package Schema::Result::Book;

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';
#use base qw/Schema::Base::Result/;
extends qw/Schema::Base::Result/;

__PACKAGE__->table("book");
__PACKAGE__->add_columns(

	qw/isbn title publish_date publish_year category_id price classification/
);

__PACKAGE__->add_base_columns;

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint([qw/isbn/]);

__PACKAGE__->has_many(
  "author_books",
  "Schema::Result::AuthorBooks",
  { "foreign.book_id" => "self.id" },
);
__PACKAGE__->many_to_many("authors" => "author_books"=> "author"); 

__PACKAGE__->has_one(
	"category",
	"Schema::Result::Category",
	{ "foreign.id" => "self.category_id" }
);
# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-13 21:11:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:obZUGgvkve3e6mzPk8GEEg

sub extra_columns {
    
    my $self = shift;

    return qw/subtitle description toc/;
};
# You can replace this text with custom content, and it will be preserved on regeneration


__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;