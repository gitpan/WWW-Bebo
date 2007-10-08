package WWW::Bebo;

use warnings;
use strict;
use WWW::Sitebase::Navigator -Base;

=head1 NAME

WWW::Bebo - Automate interaction with Bebo.com

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

This module provides methods to automate interaction with your
BeBo.com account.

    use WWW::Bebo;

    my $bebo = WWW::Bebo->new();

=cut

# Basic data for this site (see WWW::Sitebase::Navigator)
field site_info => {
    home_page => 'http://www.bebo.com/', # URL of site's homepage
    account_field => 'EmailUsername', # Fieldname from the login form
    password_field => 'Password', # Password fieldname
    cache_dir => '.www-bebo',
    login_form_no => 2, # Second form on the page
    login_verify_re => 'Sign Out', # (optional)
        # Non-case-sensitive RE we should see once we're logged in
    not_logged_in_re => '<title>Sign In<\/title>',
        # If we log in and it fails (bad password, account suddenly
        # gets logged out), the page will have this RE on it.
        # Case insensitive.
    home_uri_re => '\/Profile\.jsp\?MyProfile=Y\$',
        # _go_home uses this and the next two items to load
        # the home page.  You can provide these options or
        # just override the method.
        # First, this is matched against the current URL to see if we're
        # already on the home page.
    home_link_re => '\/Profile\.jsp\?MyProfile=Y',
        # If we're not on the home page, this RE is 
        # used to find a link to the "Home" button on the current
        # page.
    home_url => 'http://www.bebo.com/Profile.jsp?MyProfile=Y',
        # If the "Home" button link isn't found, this URL is
        # retreived.
};


# This is optional.  If the site you're navigating displays
# error pages that do not return proper HTTP Status codes
# (i.e. returns a 200 but displays an error), you can enter
# REs here and any page that matches will be retried.
#field error_regexps => [
#   'An unexpected error has occurred'
#];

# Override the _submit_login method so we can explicitly provide the 
# submit button name (primarily so it'll fail clearly if the form moves).

sub _submit_login {

    return $self->submit_form(
                    page => $self->site_info->{'home_page'},
                    form_name => $self->site_info->{'login_form_name'},
                    form_no => $self->site_info->{'login_form_no'},
                    button => 'SignIn',
                    fields_ref => {
                      $self->site_info->{'account_field'} => $self->account_name,
                      $self->site_info->{'password_field'} => $self->password
                    }
                  );

}

=head1 METHODS

=head2 post_blog( %options )

 Post a blog entry to your personal page.

 $bebo->post_blog(
    subject => $subject,  # Subject of the blog
    message => $message,  # Body of the blog
 );

=cut

sub post_blog {

    my ( %options ) = @_;
    
    $self->_go_home;
    
    if ( $options{band_id} ) {
        $self->_debug( "Getting Bebo Bands page\n" );
        $self->follow_link( url_regex => qr/Bands\.jsp/oi,
                            re => '<title>\s*Music\s*<\/title>',
                          ) or return undef;
        $self->_debug("Getting Band page for " . $options{band_id});
        $self->follow_to( 'http://www.bebo.com/Profile.jsp?MemberId=' .
                          $options{band_id},
                          'Band Members' ) or return undef;
    }
    
    $self->_debug("Clicking Write to (My )?Blog\n");
    $self->follow_link( text_regex => qr/Write To (My )?Blog/oi,
                        re => 'Write To (My )?Blog'
                      ) or return undef;
    $self->_debug("Submitting Blog form\n");
    $self->submit_form( form_no => 2,
                        fields_ref => {
                            Subject => $options{subject},
                            Message => $options{message},
                        },
                        re2 => 'Posted By|0 minutes ago',
                      ) or return undef;

    return 1;

}

sub _debug {
    my ( $message ) = @_;
    
#   warn $message . "\n";

}

=head2 post_band_blog( %options )

Same as post_blog, but posts it to the specified band's page instead
of to your personal page.  Logged in user must of course have access
to post bulletins for the specified band (i.e. must be a band member).

 $bebo->post_band_blog(
     band_id => $band_id,  # ID of the band. Go to the band page and
                           # Look in the URL for GrpID=123456. Logged in user
                           # must have access.
                           # If not included, posts to the logged-in user's
                           # home page.
     subject => $subject,
     message => $message
 )

=cut
     
sub post_band_blog {

    # This is *currently* identical to post_blog, but we keep them
    # separated in case Bebo changes things such that we need to break
    # into separate code.
    $self->post_blog( @_ );

}

=head1 AUTHOR

Grant Grueninger, C<< <grantg at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-bebo at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Bebo>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Bebo

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Bebo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Bebo>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Bebo>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Bebo>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Grant Grueninger, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WWW::Bebo
