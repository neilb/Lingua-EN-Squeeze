# Steps to make CPAN package:
#
# 1. Modify this file as needed
# 2. Create Makefile "perl Makefile.PL"
# 3. run "make manifest" and check MANIFEST file, check with "make distcheck"
# 4. Regenerate META.yml with "rm META.yml; make metafile"
# 5. Run "make dist" and check *tar.gz
#
# Another way to make a CPAN package
#
#   $ mkdir -p Lingua-EN-Squeeze-YYYY.MMDD
#   $ cp Squeeze.pm Makefile.PL INSTALL Lingua-EN-Squeeze-YYYY.MMDD
#   $ cp Makefile.PL Lingua-EN-Squeeze-YYYY.MMDD
#   $ tar zvcf Lingua-EN-Squeeze-YYYY.MMDD.tar.gz Lingua-EN-Squeeze-YYYY.MMDD/
#
# Other targets
#
#   $ make distdir distcheck dist

use ExtUtils::MakeMaker;

$MODULE    = 'Lingua::EN::Squeeze';

WriteMakefile
(
    NAME                => $MODULE
    , VERSION_FROM      => 'Squeeze.pm'          # finds $VERSION

    , ABSTRACT          => 'Shorten text to minimum syllables by '
                         . 'using hash table lookup and vowel deletion'

    , AUTHOR            => '<jariaalto@cpan.org>'

    , PREREQ_PM         =>
    {
        'Test::More'    => 0
    }

    , dist              =>
    {
            COMPRESS    => 'gzip'
        ,   SUFFIX      => 'gz'
    }
);

#   perl -MCPAN -e 'install YAML'
#
#   Override MakeMaker Methods.
#   See 'perldoc  ExtUtils::MM_Unix' => METHODS
#
#   http://www.mail-archive.com/makemaker@perl.org/msg01664.html
#   http://www.perlpod.com/5.8.3/lib/ExtUtils/MakeMaker.html#Module%20Meta-Data

sub MY::metafile
{
    package MY;
    my $self = shift;

    eval { require YAML; 1 } or do
    {
        warn ("YAML not installed, cannot override metafile");
        return $self->SUPER::metafile_target(@_);
    };

    my $node = new YAML::Node {};

    #  See http://module-build.sourceforge.net/META-spec.html

    $node->{name}               = $self->{DISTNAME};
    $node->{version}            = $self->{VERSION};
    $node->{license}            = 'gpl';

    $node->{distribution_type}  = 'module';
    $node->{requires}           = $self->{PREREQ_PM};

    $node->{installdirs}        = 'site';

    #$node->{generated_by}     = "$main::MODULE $0";
    $node->{generated_by}      =
        "$self->{DISTNAME} version $self->{VERSION} ($0)";

    my $dump                    = YAML::Dump($node);

    $dump =~ s/^(.*)$/\t\$(NOECHO) \$(ECHO) "$1" >>META.yml/gm;
    $dump =~ s/>>META\.yml/>META.yml/;

    return "metafile:\n$dump";
}

# End of file
