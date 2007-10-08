#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Bebo' );
}

diag( "Testing WWW::Bebo $WWW::Bebo::VERSION, Perl $], $^X" );
