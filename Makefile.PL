use ExtUtils::MakeMaker;

# Steps to make CPAN package:
#
# 1. Modify this file as needed
# 2. Create Makefile (perl Makefile.PL)
# 3. run "make manifest" and check MANIFEST file
# 4. make dist and check *tar.gz
#
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
    NAME	       => 'Lingua::EN::Squeeze'
    , VERSION_FROM   => 'Squeeze.pm'		# finds $VERSION

    , dist	       =>
    {
	    COMPRESS	=> 'gzip'
	,   SUFFIX	=> 'gz'
    }
);
