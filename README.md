# Sample GitHub Actions workflow for Dist::Zilla based distributions

Here's a sample workflow for `Dist::Zilla` based distributions, to use with
GitHub Actions.

It's a two-staged build:

- 1. Use a current Perl release, to build a release tarball,
- 2. Test that release tarball across a variety of Perl versions

Sounds pretty simple, right?

I thought so too, until I started setting it up.  :)

Turned out there were a few hiccups that I'd bump into along the way, which I
needed to get ironed out.

## What you'll find here

The following `workflows/` are provided, and are suitable for copying into
your `.github/workflows/` directory in your repository.

### `workflows/perl-ci.yml`

Two-stage workflow, suitable for _most_ of my needs.

### `workflows/perl-ci-with-recommends.yml`

Same two-stage workflow, but with separate matrix entries for running tests in
the second stage "with" and "without" recommended dependencies installed.

Useful when a distribution has "recommends", and I want to make sure that the
test suite will pass even if those modules aren't installed.

## Things I learned while setting this up

### Two-stage builds better replicate the final results

Sure, we could rig up a one-stage build that installs all of our dependencies
and then runs `dzil test` across a variety of Perl versions.  But, that's
really testing "does the _author's version_ of the distribution build/test
successfully?"

What I really wanted, was to replicate the results of

- a) Can I build the distribution on my end, and turn that into a tarball to upload to CPAN? and,
- b) Does the tarball I upload to CPAN build/test properly for everyone else?

Using a two-stage build does just that; we do the initial build just like it
would be performed by the Author, and then we carry forwards the distribution
tarball into the second stage where we can test it against a matrix of different
Perl versions.

### Be aware... `actions/checkout@v2` does not always use `git`

Depending on what version of `git` is installed, `actions/checkout@v2` may
instead use the GitHub REST API to check out your source.

**If** you actually need to have a `.git/` directory around for any of the
tests that you want to run, then use `actions/checkout@v1` instead.

### Use `perldocker/perl-tester:latest` during the first build

The `perldocker/perl-tester:*` images _already_ have `Dist::Zilla` and a
bunch of other testing related modules installed, and that helps save a **ton**
of time during your build.

### Use `perl-actions/install-with-cpm@stable` during the first build

Going on the presumption that you are using an Author Bundle of one sort or
another, you likely only have a _single_ distribution that you need to install
as Author Dependencies (but that it may then in turn depend on a whole bunch of
other stuff).

[atoomic](https://github.com/atoomic) has provided with a series of
[perl-actions](https://github.com/perl-actions) that we can use during our
GitHub Actions workflows, including
[perl-actions/install-with-cpm](https://github.com/perl-actions/install-with-cpm)
which installs modules using [cpm](https://metacpan.org/release/App-cpm).

`cpm` will install all of our dependencies in parallel, which will keep the
time down on this initial build.

### Use `perl-actions/install-with-cpanm@v1` during the second build

Although [cpanm](https://metacpan.org/release/App-cpanminus) won't install
distributions in parallel, it **will** install dependencies directly from your
generated `META.json` file (you **did** use `[MetaJSON]` in your `dist.ini` to
make sure that you generated a `META.json` file, didn't you?)  Thus, no need to
include a `cpanfile` in the distribution tarball.

Further, doing this install as `cpanm --installdeps .` will ensure that you're
installing _just_ the dependencies and not your module itself.  While I'd love
to use `cpm` here and get parallel installs, it does not yet support the
`--installdeps` command line option.

Also, note that this one is `@v1`, as (as of this writing), `@stable` is an
older release and does not support the ability for us to pass through
`--installdeps .`

# Author

Graham TerMarsch (cpan@howlingfrog.com)

# See Also

- [Dist::Zilla](https://metacpan.org/pod/Dist%3A%3AZilla)
- [perldocker/perl-tester](https://github.com/Perl/docker-perl-tester)
- [perl-actions/install-with-cpm](https://github.com/perl-actions/install-with-cpm)
- [perl-actions/install-with-cpanm](https://github.com/perl-actions/install-with-cpanm)
