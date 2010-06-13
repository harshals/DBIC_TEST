package DBIC_TEST::View::HTML;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config( {
    INCLUDE_PATH => [
        DBIC_TEST->path_to( 'root', 'src' ),
        DBIC_TEST->path_to( 'root', 'lib' ),
        DBIC_TEST->path_to( 'root', 'static' )
    ],
	TEMPLATE_EXTENSION => '.tt'
    },
);


