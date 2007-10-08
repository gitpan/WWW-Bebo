use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Bebo',
    license             => 'perl',
    dist_author         => 'Grant Grueninger <grantg@cpan.org>',
    dist_version_from   => 'lib/WWW/Bebo.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'WWW::Sitebase::Navigator' => 0.03,
    },
    add_to_cleanup      => [ 'WWW-Bebo-*' ],
);

$builder->create_build_script();
