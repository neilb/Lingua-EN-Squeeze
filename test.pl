#!/usr/local/bin/perl

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN
{
    use Env;
    use lib "$HOME/bin2";
    use English;

    $OUTPUT_AUTOFLUSH = 1;

    my $std = "Lingua::EN::Squeeze";

    eval "use $std qw( :ALL )";

    if ( $EVAL_ERROR )
    {
	print "$std default load failed failed\n";

	use Cwd;
	unshift @INC, cwd;

	eval "use Squeeze qw( :ALL )";
	die  $EVAL_ERROR if $EVAL_ERROR;

	if ( not defined &SqueezeText )
	{
	    die "Fatal error, cannot load Squeeze.pm from @INC";
	}

    }
}

# ***********************************************************************
#
#   Closures
#
# ***********************************************************************

{
    my $test = 1;

sub ok (;$)
{
    my $msg = shift;
    print "ok     ", $test++, " $msg\n";
}

sub nok (;$)
{
    my $msg = shift;
    print "NOT ok ", $test++, " $msg\n";
}}

# ***********************************************************************
#
#   Tests
#
# ***********************************************************************

my $str =
    "This is piece of text to demonstrate the Squeezing algorhithm\n";

my $levelString =
    "With or without piece translate differently, LEVEL is adjusted\n";

print "TEST STRING 1\n\t$str"
    , "TEST STRING 2\n\t$levelString\n"
    , "\n"
    ;


eval
{

    # ........................................................ &test ...

    $ARG = SqueezeText($str);

    if ( $ARG ne '' )
    {
	ok $ARG,
    }
    else
    {
	nok "Panic, No output";
    }




    # ........................................................ &test ...

    my $val	= "piece";
    my $cnv	= "TO_MY_CNV";
    my %myHash	=
    (
	$val => $cnv
    );


    SqueezeHashSet( \%myHash );

    $ARG =  SqueezeText($str);

    if ( /$cnv/o )
    {
	ok $ARG;
    }
    else
    {
	nok "SqueezeHashSet()"; print;
    }


    # ........................................................ &test ...

    $str = $levelString;
    $len = length $str;

    SqueezeControl( "noconv" );
    $ARG =  SqueezeText($str);

    if ( $len == length )
    {
	ok "Level none: $ARG";
    }
    else
    {
	nok "SqueezeControl(none)"; print;
    }

    # ........................................................ &test ...


    $str = $levelString;
    SqueezeControl( "med" );
    $ARG =  SqueezeText($str);

#    print "KEYS >>", join ' ', keys %Lingua::EN::Squeeze::wordXlate, "\n\n";

    if (  ! m,w/t, )
    {
	my $ratio = sprintf "%0.2f%%",  1 - length($ARG)/length $levelString;
	ok "Level med: $ratio $ARG";
    }
    else
    {
	nok "SqueezeControl(med) $ARG";
    }

    # ........................................................ &test ...

#    SqueezeDebug(1, "without");

    $str = $levelString;
    SqueezeControl( "max" );
    $ARG =  SqueezeText($str);

#    print "KEYS >>", join ' ', keys %Lingua::EN::Squeeze::wordXlate, "\n\n";

    if ( m,w/, )
    {
	my $ratio = sprintf "%0.2f%%",  1 - length($ARG)/length $levelString;
	ok "Level max: $ratio  $ARG";
    }
    else
    {
	nok "SqueezeControl(max) $ARG";
    }



    # ........................................................ &test ...

=pod
    $str = $levelString;
    $obj = new Lingua::EN::Squeeze;

    $ARG =  $obj->SqueezeText($str);

    if ( m,w/, )
    {
	ok "Level max: $ARG";
    }
    else
    {
	nok "OBJECT contruction failed: $ARG";
    }
=cut

};



if ( $EVAL_ERROR )
{
    print "... error: $EVAL_ERROR\n";
}

# End of file test.pl
