package Sample;

our $VERSION = '0.01';

# ABSTRACT: Sample GitHub Actions workflows, for a Dist::Zilla based distribution

=head1 Sample GitHub Actions workflow for Dist::Zilla based distributions

Here's a sample workflow for C<Dist::Zilla> based distributions, to use with
GitHub Actions.

It's a two-staged build:

=over

=item 1. Use a current Perl release, to build a release tarball,

=item 2. Test that release tarball across a variety of Perl versions

=back

Sounds pretty simple, right?

I thought so too, until I started setting it up.  :)

Turned out there were a few hiccups that I'd bump into along the way, which I
needed to get ironed out.

=head2 Things I learned while setting this up

=head3 Two-stage builds better replicate the final results

Sure, we could rig up a one-stage build that installs all of our dependencies
and then runs C<dzil test> across a variety of Perl versions.  But, that's
really testing "does the I<author's version> of the distribution build/test
successfully?"

What I really wanted, was to replicate the results of

=over

=item a) Can I build the distribution on my end, and turn that into a tarball to upload to CPAN? and,

=item b) Does the tarball I upload to CPAN build/test properly for everyone else?

=back

Using a two-stage build does just that; we do the initial build just like it
would be performed by the Author, and then we carry forwards the distribution
tarball into the second stage where we can test it against a matrix of different
Perl versions.

=head3 Be aware... C<actions/checkout@v2> does not always use C<git>

Depending on what version of C<git> is installed, C<actions/checkout@v2> may
instead use the GitHub REST API to check out your source.

B<If> you actually need to have a F<.git/> directory around for any of the
tests that you want to run, then use C<actions/checkout@v1> instead.

=head3 Use C<perldocker/perl-tester:latest> during the first build

The C<perldocker/perl-tester:*> images I<already> have C<Dist::Zilla> and a
bunch of other testing related modules installed, and that helps save a B<ton>
of time during your build.

=head3 Use C<perl-actions/install-with-cpm@stable> during the first build

Going on the presumption that you are using an Author Bundle of one sort or
another, you likely only have a I<single> distribution that you need to install
as Author Dependencies (but that it may then in turn depend on a whole bunch of
other stuff).

L<atoomic|https://github.com/atoomic> has provided with a series of
L<perl-actions|https://github.com/perl-actions> that we can use during our
GitHub Actions workflows, including
L<perl-actions/install-with-cpm|https://github.com/perl-actions/install-with-cpm>
which installs modules using L<cpm|https://metacpan.org/release/App-cpm>.

C<cpm> will install all of our dependencies in parallel, which will keep the
time down on this initial build.

=head3 Use C<perl-actions/install-with-cpanm@v1> during the second build

Although L<cpanm|https://metacpan.org/release/App-cpanminus> won't install
distributions in parallel, it B<will> install dependencies directly from your
generated F<META.json> file (you B<did> use C<[MetaJSON]> in your F<dist.ini> to
make sure that you generated a F<META.json> file, didn't you?)  Thus, no need to
include a F<cpanfile> in the distribution tarball.

Further, doing this install as C<cpanm --installdeps .> will ensure that you're
installing I<just> the dependencies and not your module itself.  While I'd love
to use C<cpm> here and get parallel installs, it does not yet support the
C<--installdeps> command line option.

Also, note that this one is C<@v1>, as (as of this writing), C<@stable> is an
older release and does not support the ability for us to pass through
C<--installdeps .>

=head1 Author

Graham TerMarsch (cpan@howlingfrog.com)

=head1 See Also

=over

=item L<Dist::Zilla>

=item L<perldocker/perl-tester|https://github.com/Perl/docker-perl-tester>

=item L<perl-actions/install-with-cpm|https://github.com/perl-actions/install-with-cpm>

=item L<perl-actions/install-with-cpanm|https://github.com/perl-actions/install-with-cpanm>

=back

=cut
