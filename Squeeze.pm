# @(#) Squeez.pm - Perl package to Shorten text to minimum syllables
# @(#) $Id: Squeeze.pm,v 1.25 1998/12/04 10:00:08 jaalto Exp $
#
#	This file is maintaned by using Emacs and packages
#
#	    tinytab.el	-- 4 tab movement mode
#	    tinyperl	-- Perl helper mode (pod docs, stubs etc)
#	    tinybm.el	-- those drawn &TAG lines and breaks you see
#

package Lingua::EN::Squeeze;

my $LIB = "Lingua::EN::Squeeze";	# For function debug


    use vars qw ( $VERSION );

    #	This is for use of Makefile.PL and ExtUtils::MakeMaker
    #	So that it puts the tardist number in format YYYY.MMDD
    #	The REAL version number is defined later

    #	The following variable is updated by my Emacs setup whenever
    #	this file is saved

    $VERSION = '1998.1204';

# ***********************************************************************
#
#   POD HEADER
#
# ***********************************************************************

=pod

=head1 NAME

Squeeze.pm - Shorten text to minimum syllables by using hash table and
vowel deletion

=head1 REVISION

$Id: Squeeze.pm,v 1.25 1998/12/04 10:00:08 jaalto Exp $

=head1 SYNOPSIS

    use Squeeze.pm;	    # imnport only function
    use Squeeze qw( :ALL ); # import all functions and variables
    use English;

    while (<>)
    {
	print SqueezeText $ARG;
    }

=head1 DESCRIPTION

Squeeze English text to most compact format possibly so that it is barely
readable. You should convert all text to lowercase for maximum compression,
because optimizations have been designed mostly fr uncapitalised letters.

=over 4

C<Warning: Each line is processed multiple times, so prepare for slow
conversion time>

=back

You can use this module e.g. to preprocess text before it is sent to
electronic media that has some maximum text size limit. For example pagers
have an arbitrary text size limit, typically 200 characters, which you want
to fill as much as possible. Alternatively you may have GSM cellular phone
which is capable of receiving Short Messages (SMS), whose message size
limit is 160 characters. For demonstration of this module's SqueezeText()
function , the description text of this paragraph has been converted below.
See yourself if it's readable (Yes, it takes some time to get used to). The
compress ratio is typically 30-40%

    u _n use thi mod e.g. to prprce txt bfre i_s snt to
    elrnic mda has som max txt siz lim. f_xmple pag
    hv  abitry txt siz lim, tpcly 200 chr, W/ u wnt
    to fll as mch as psbleAlternatvly u may hv GSM cllar P8
    w_s cpble of rcivng Short msg (SMS), WS/ msg siz
    lim is 160 chr. 4 demonstrton of thi mods SquezText
    fnc ,  dsc txt of thi prgra has ben cnvd_ blow
    See uself if i_s redble (Yes, it tak som T to get usdto
    compr rat is tpcly 30-40

And if $SQZ_OPTIMIZE_LEVEL is set to non-zero

    u_nUseThiModE.g.ToPrprceTxtBfreI_sSntTo
    elrnicMdaHasSomMaxTxtSizLim.F_xmplePag
    hvAbitryTxtSizLim,Tpcly200Chr,W/UWnt
    toFllAsMchAsPsbleAlternatvlyUMayHvGSMCllarP8
    w_sCpbleOfRcivngShortMsg(SMS),WS/MsgSiz
    limIs160Chr.4DemonstrtonOfThiModsSquezText
    fnc,DscTxtOfThiPrgraHasBenCnvd_Blow
    SeeUselfIfI_sRedble(Yes,ItTakSomTToGetUsdto
    comprRatIsTpcly30-40

The comparision of these two show

    Original text   : 627 characters
    Level 0	    : 433 characters	reduction 31 %
    Level 1	    : 345 characters	reduction 45 %	(+14 improvement)

There are few grammar rules which are used to shorten some English
tokens very much:

    Word that has _ is usually a verb

    Word that has / is usually a substantive, noun,
		    pronomine or other non-verb

For example, these tokens must be understood before text can be read. This
is not yet like Geek code, because you don't need external parser to
understand this, but just some common sense and time to adapt yourself to
this text. I<For a complete up to date list, you have to peek the source
code>

    automatically => 'acly_'

    for           => 4
    for him       => 4h
    for her       => 4h
    for them      => 4t
    for those     => 4t

    can           => _n
    does          => _s

    it is         => i_s
    that is       => t_s
    which is      => w_s
    that are      => t_r
    which are     => w_r

    less          => -/
    more          => +/
    most          => ++

    however       => h/ver
    think         => thk_

    useful        => usful

    you           => u
    your          => u/
    you'd         => u/d
    you'll        => u/l
    they          => t/
    their         => t/r

    will          => /w
    would         => /d
    with          => w/
    without       => w/o
    which         => W/
    whose         => WS/


Time is expressed with big letters

    time          => T
    minute        => MIN
    second        => SEC
    hour          => HH
    day           => DD
    month         => MM
    year          => YY

Other Big letter acronyms

    phone	  => P8

=head1 EXAMPLES

To add new words e.g. to word conversion hash table, you'd define your
custom set and merge them to existing ones. Do similarly to
C<%SQZ_WXLATE_MULTI_HASH> and C<$SQZ_ZAP_REGEXP> and then start using the
conversion function.

    use English;
    use Squeeze qw( :ALL );

    my %myExtraWordHash =
    (
	  new-word1  => 'conversion1'
	, new-word2  => 'conversion2'
	, new-word3  => 'conversion3'
	, new-word4  => 'conversion4'
    );

    #	First take the existing tables and merge them with my
    #	translation table

    my %mySustomWordHash =
    (
	  %SQZ_WXLATE_HASH
	, %SQZ_WXLATE_EXTRA_HASH
	, %myExtraWordHash
    );

    my $myXlat = 0;				# state flag

    while (<>)
    {
	if ( $condition )
	{
	    SqueezeHashSet \%mySustomWordHash;	# Use MY conversions
	    $myXlat = 1;
	}

	if ( $myXlat and $condition )
	{
	    SqueezeHashSet "reset";		# Back to default table
	    $myXlat = 0;
	}

	print SqueezeText $ARG;
    }

Similarly you can redefine the multi word translate table by supplying
another hash reference in call to SqueezeHashSet(). To kill more text
immediately in addtion to default, just concatenate the regexps to
I<$SQZ_ZAP_REGEXP>

=head1 KNOWN BUGS

There may be lot of false conversions and if you think that some word
squeezing went too far, please 1) turn on the debug 2) send you example
text 3) debug log log to the maintainer. To see how the conversion goes
e.g. for word I<Messages>:

    use English;
    use Lingua::EN:Squeeze;

    #	activate debug when case-insensitive worj "Messages" is found from the
    #	line.

    SqueezeDebug( 1, '(?i)Messages' );

    $ARG = "This line has some Messages in it";
    print SqueezeText $ARG;


=head1 EXPORTABLE VARIABLES

The defaults may not conquer all possible text, so you may wish to
extend the hash tables and I<$SQZ_ZAP_REGEXP> to cope with your typical text.

=over 4

=head2 $SQZ_ZAP_REGEXP

Text to kill immediately, like "Hm, Hi, Hello..." You can only set this
once, because this regexp is compiled immediately when C<SqueezeText()> is
caller for the first time.

=head2 $SQZ_OPTIMIZE_LEVEL

This controls how optimized the text will be. Curretly there is only
levels 0 (default) and level 1, which squeezes out all spaces. This
improves compression by average of 10%, but the text is more harder to
read. If space is tight, use this extended compression optimization.

=head2 %SQZ_WXLATE_MULTI_HASH

I<Multi Word> conversion hash table:  "for you" => "4u" ...

=head2 %SQZ_WXLATE_HASH

I<Single Word> conversion hash table: word => conversion. This table is applied
after C<%SQZ_WXLATE_MULTI_HASH> has been used.

=head2 %SQZ_WXLATE_EXTRA_HASH

Aggressive I<Single Word> conversions like: without => w/o. Applied last.

=back

=cut

# ......................................................... &pod-end ...



# ******************************************************* &interface ***
#
#   MODULE INTERFACE
#
# ***********************************************************************

BEGIN { require 5.003 }

use strict;

# Somehow doesn't work in Perl 5.004 ?
# use autouse 'Carp'          => qw( croak carp cluck confess );

use Carp;
use SelfLoader;
use English;

BEGIN
{
    # ......................................................... &use ...

    use vars qw
    (
	@ISA
	@EXPORT
	@EXPORT_OK
	%EXPORT_TAGS

	$FILE_ID

	$debug
	$debugRegexp

	$SQZ_ZAP_REGEXP
	$SQZ_OPTIMIZE_LEVEL

	%SQZ_WXLATE_HASH
	%SQZ_WXLATE_EXTRA_HASH
	%SQZ_WXLATE_MULTI_HASH
    );

    $FILE_ID =
	q$Id: Squeeze.pm,v 1.25 1998/12/04 10:00:08 jaalto Exp $;

    #	Here is the real version number, which you use like this:
    #
    #	    use Squeeze 1.34;
    #
    #   Derive version number, the index is 1 if matches
    #   Clearcase @@ in file_id string. index is 2 if this was
    #   RCS identifier.

    my $ver = (split ' ', $FILE_ID)[$FILE_ID =~ /@@/ ? 1 : 2];
    $VERSION = sprintf "%d.%02d",  $ver =~ /(\d+)\.(\d+)/;

    # ...................................................... &export ...

    use Exporter ();

    @ISA         = qw(Exporter);

    @EXPORT      = qw
    (
	&SqueezeText
	&SqueezeControl
	&SqueezeDebug
    );

    @EXPORT_OK   = qw
    (
	&SqueezeHashSet

	$SQZ_ZAP_REGEXP
	$SQZ_OPTIMIZE_LEVEL

	%SQZ_WXLATE_HASH
	%SQZ_WXLATE_EXTRA_HASH
	%SQZ_WXLATE_MULTI_HASH
    );

    %EXPORT_TAGS =
    (
	ALL => [ @EXPORT_OK, @EXPORT ]
    );

}


# ********************************************************* &globals ***
#
#   GLOBALS
#
# **********************************************************************

$debug		= 0;
$debugRegexp	= '(?i)DummyJummy';

$SQZ_ZAP_REGEXP =
	'\b(a|an|the|shall|hi|hello|cheers|that)\b'
    .   '|Thanks (in advance)?|thank you|well'
    .	'|N\.B\.|\beg.|\btia\b'
    .	'|\bHi,?\b|\bHm+,?\b'
    .	'|!'
    .	'|wrote:|writes:'

    #	Finnish greetings

    .   '|\b(Terve|Moi|Hei|Huomenta)\b'

    ;

$SQZ_OPTIMIZE_LEVEL = 0;

# ............................................................ &word ...
#   A special mnemonic is signified by postfixing it with either
#   of these characters:
#
#	/	prononym, noun
#	_	verb

%SQZ_WXLATE_HASH =
(
      above	    => 'abve'
    , address	    => 'addr'
    , adjust	    => 'adj'
    , adjusted	    => 'ajusd'
    , adjustable    => 'ajutbl'
    , arbitrary	    => 'abitry'
    , argument	    => 'arg'

    , backgreound   => 'bg'
    , below	    => 'blow'

    , change	    => 'chg'
    , character     => 'chr'
    , control	    => 'ctl'
    , command	    => 'cmd'
    , compact	    => 'cpact'
    , convert	    => 'cnv_'
    , converted	    => 'cnvd_'
    , conversion    => 'cnv'
    , cooperation   => 'c-o'
    , correct	    => 'corr'
    , correlate	    => 'corrl'
    , create	    => 'creat'

    , database      => 'db'
    , day           => 'DD'
    , date	    => 'DD'
    , definition    => 'defn'
    , description   => 'desc'
    , different	    => 'dif'
    , differently   => 'difly'
    , directory     => 'dir'
    , documentation => 'doc'
    , document	    => 'doc/'

    , 'each'	    => 'ech'
    , electronic    => 'elrnic'
    , electric      => 'elric'
    , enable	    => 'enbl'
    , english	    => 'eng'
    , environment   => 'env'
    , everytime     => 'when'
    , example	    => 'xmple'
    , expire	    => 'xpre'
    , expect	    => 'exp'
    , extend	    => 'extd'

    , field         => 'fld'
    , following     => 'fwng'
    , 'for'         => '4'
    , 'format'	    => 'fmt'
    , forward       => 'fwd'
    , function	    => 'func'

    , gateway       => 'gtw'
    , generated     => 'gntd'

    , have	    => 'hv'
    , herself       => 'hself'
    , himself       => 'hself'
    , hour	    => 'HH'

    , identifier    => 'id'
    , information   => 'inf'
    , inform	    => 'ifrm'
    , increase	    => 'inc'
    , installed     => 'ins'

    , level	    => 'lev'
    , limit	    => 'lim'
    , limiting	    => 'limg'
    , located       => 'loctd'
    , lowercase	    => 'lc'

    , managed       => 'mged'
    , megabyte	    => 'meg'
    , maximum	    => 'max'
    , member        => 'mbr'
    , message       => 'msg'
    , minute	    => 'MIN'
    , minimum	    => 'min'
    , module	    => 'mod'
    , month         => 'MM'


    , 'name'	    => 'nam'
    , 'number'	    => 'nbr'

    , okay	    => 'ok'
    , 'other'	    => 'otr'
    , 'others'	    => 'otr'

    , 'package'     => 'pkg'
    , page	    => 'pg'
    , parameter	    => 'param'
    , password	    => 'pwd'
    , pointer	    => 'ptr'
    , public	    => 'pub'
    , private	    => 'priv'
    , problem       => 'prb'
    , process	    => 'proc'
    , project       => 'prj'

    , recipient	    => 'rcpt'	    # this is SMTP acronym
    , released	    => 'relsd'
    , reserve	    => 'rsv'
    , register      => 'reg'
    , resource      => 'rc'
    , return	    => 'ret'
    , returned	    => 'ret'
    , 'require'	    => 'rq'

    , subject	    => 'sbj'
    , soconds	    => 'SEC'
    , service       => 'srv'
    , squeeze	    => 'sqz'
    , something     => 'stng'
    , sometimes     => 'stims'
    , status	    => 'stat'
    , still	    => 'stil'
    , straightforward => 'sfwd'
    , submit	    => 'sbmit'
    , submitting    => 'sbmtng'
    , symbol	    => 'sym'
    , 'system'	    => 'sytm'

    , 'time'        => 'T'
    , translate     => 'tras'

    , understand    => 'untnd'
    , uppercase	    => 'uc'
    , usually	    => 'usual'

    , year          => 'YY'
    , you           => 'u'
    , your          => 'u/'
    , yourself      => 'uself'

    , 'version'	    => 'ver'

    , warning	    => 'warng'
    , with          => 'w/'
    , work          => 'wrk'

);

%SQZ_WXLATE_EXTRA_HASH =
(
      anything	    => 'atng'
    , automatically => 'acly_'

    , can	    => '_n'

    , does	    => '_s'
    , dont	    => '_nt'
    , "don't"	    => '_nt'
    , 'exists'	    => 'ex_'

    , everything    => 'etng/'

    , however	    => 'h/ver'

    , increment	    => 'inc/'
    , interesting   => 'inrsg'
    , interrupt	    => 'irup'

    #	 not spelled like 'less', because plural substitution seens
    #	 this first 'less' -> 'les'

    , 'les'	    => '-/'

    , 'more'	    => '+/'
    , most	    => '++'

    , phone	    => 'P8'
    , please	    => 'pls_'
    , person	    => 'per/'

    , should        => 's/d'
    , they          => 't/'
    , their         => 't/r'
    , think	    => 'thk_'
    , 'which'	    => 'W/'
    , without       => 'w/o'
    , whose	    => 'WS/'
    , will	    => '/w'
    , would	    => '/d'

    , "you'd"       => 'u/d'
    , "you'll"      => 'u/l'

);

# ........................................................... &multi ...

%SQZ_WXLATE_MULTI_HASH =
(
      'for me'	    => '4m'
    , 'for you'	    => '4u'
    , 'for him'	    => '4h'
    , 'for her'	    => '4h'
    , 'for them'    => '4t'
    , 'for those'   => '4t'

    , 'for example' => 'f_xmple'

    , 'with or without' => 'w/o'


    , 'it is'	    => 'i_s'
    , "it's"	    => 'i_s'

    , 'that is'	    => 't_s'
    , "that's"	    => 't_s'
    , "that don't"  => 't_nt'

    , 'which is'    => 'w_s'
    , "which's"     => 'w_s'
    , "which don't" => 'w_nt'

    , 'that are'	=> 't_r'
    , "that're"		=> 't_r'
    , "that are not"	=> 't_rt'

    , 'which are'	=> 'w_r'
    , 'which are not'   => 'w_rt'
    , "which aren't"	=> 'w_rt'

    , "has not"		=> 'hs_t'
    , "have not"	=> 'hv_t'

    , "that has"	=> 't_hs'
    , "that has not"	=> 't_hst'
    , "that hasn't"	=> 't_hst'

    , 'which has'	=> 'w_hs'
    , 'which has not'   => 'w_hst'
    , "which hasn't"	=> 'w_hst'

    , "that have"	=> 't_hv'
    , "that have not"   => 't_hvt'
    , "that haven't"	=> 't_hvt'

    , 'which have'	=> 'w_hv'
    , "which have not"	=> 'w_hvt'
    , "which haven't"	=> 'w_hvt'

    , "that had"	=> 't_hd'
    , "that had not"	=> 't_hdt'
    , "that hadn't"	=> 't_hdt'

    , 'which had'	=> 'w_hd'
    , 'which had not'	=> 'w_hdt'
    , "which hadn't"	=> 'w_hdt'

    , 'used to'	    => 'usdto'
    , 'due to'	    => 'd_to'

    , 'United Kingdom' => 'UK'
    , 'United States'  => 'US'
);


# ********************************************************* &private ***
#
#   PRIVATE VARIABLES
#
# **********************************************************************

#   We must declare package globals sot hat SelfLoader sees them after
#   __DATA__

use vars qw
(
    %SQZ_WXLATE_MULTI_HASH_MEDIUM
    %SQZ_WXLATE_MULTI_HASH_MAX
    %SQZ_WXLATE_HASH_MEDIUM
    %SQZ_WXLATE_HASH_MAX
);

%SQZ_WXLATE_MULTI_HASH_MEDIUM = %SQZ_WXLATE_MULTI_HASH;
%SQZ_WXLATE_MULTI_HASH_MAX    = %SQZ_WXLATE_MULTI_HASH;

%SQZ_WXLATE_HASH_MEDIUM	      = %SQZ_WXLATE_HASH;
%SQZ_WXLATE_HASH_MAX	      = ( %SQZ_WXLATE_HASH, %SQZ_WXLATE_EXTRA_HASH);

#   The Active translate tables
#
#   User isn't suppose to touch this, but in case you need to know
#   exactly what traslations are going and what table is in use, then peeek
#   these.
#
#	$Lingua::EN::Squeeze::wordXlate{above}

use vars qw
(
    %wordXlate
    %multiWordXlate
    $STATE
);

%wordXlate	= %SQZ_WXLATE_HASH_MAX;
%multiWordXlate	= %SQZ_WXLATE_MULTI_HASH;
$STATE		= "max";		# Squeeze level


# **********************************************************************
#
#   I N T E R F A C E
#
# *********************************************************************

=pod

=head1 INTERFACE FUNCTIONS

=for html
<BLOCKQUOTE>

=cut



# **********************************************************************
#
#   PUBLIC FUNCTION
#
# *********************************************************************

=pod

=over 4

=head2 SqueezeText($)

=item Description

Squeeze text by using vowel substitutions and deletions and hash tables
that guide text substitutions. The line is parsed multiple times and
this will take some time.

=item arg1: $text

String. Line of Text.

=item Return values

String, squeezed text.

=back

=cut

sub SqueezeText ($)
{

    # ....................................................... &start ...

    my	  $id	= "$LIB.SqueezeText";
    local $ARG	= shift;


    return $ARG	if $STATE eq 'noconv';	# immediate return, no conversion


    my( $from, $to );

    my $vow	= '[aeiouy]';		# vowel
    my $nvow	= '[^aeiouy\s_/\']';	# non-vowel


    my $orig	= $ARG;			# for debug
    my $tab	= "";			# tab

    # ........................................................ &kill ...

    if ( /^\s*[^\s]{30,}/ )	# Any continuous block. UU line ?
    {
	return "";
    }

    if ( /^[A-Z][^\s]+: / )	# Email headers "From:"
    {
	return "";
    }

    s/^\s+//;		# delete leading spaces
    s/[ \t]+$//;	# delete trailing spaces
    s/[ \t]+/ /g;	# collapse multiple spaces inside text

    # ........................................................ words ...

	#   Kill URLs

    s{\b\S+://\S+\b}{URL}ig;

	#   Delete markup +this+ *emphasised* *strong* `text'

    s/\b[_*+`'](\S+)[_*+`']\b/$1/ig;
    $debug and warn $tab,"[markup]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#   Delete 3rd person voice
	#   expires => expire
	#
	#   But do not touch 'was'

    s/\b($vow\S+$vow)s\b/$1/ogi;

	#   says    => say

    s/\b($nvow+\S$vow+)s\b/$1/ogi;

	#   vowel .. nvowel + 2
	#   interests => interest

    s/\b($vow\S+$nvow)s\b/$1/ogi;
    $debug and warn $tab,"[3voice]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#   Delete plurals: non-vowel .. non-vowel + s
	#   problems  => problem

    s/\b($nvow\S+$nvow)s\b/$1/ogi;
    $debug and warn $tab,"[plural]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#   Delete plurals: non-vowel .. vowel + s
	#   messages => message

    s/\b($nvow\S+$vow)s\b/$1/ogi;
    $debug and warn $tab,"[plural2]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#   zap

    s/$SQZ_ZAP_REGEXP//oig;
    $debug and warn $tab,"[zap]\t\t[$ARG]" if $orig =~ /$debugRegexp/;


    # ................................................... &translate ...

    for $from ( keys %multiWordXlate  )
    {
	$to = $multiWordXlate{ $from };
	s/\b$from\b/$to/ig;
    }

    $debug and warn $tab,"[xlate-multi]\t[$ARG]" if $orig =~ /$debugRegexp/;

    for $from ( keys %wordXlate )
    {
	$to = $wordXlate{ $from };
	s/\b$from\b/$to/ig;
    }


    $debug and warn $tab,"[xlate-word]\t[$ARG]" if $orig =~ /$debugRegexp/;

    # ...................................................... &suffix ...

	#   From Imperfect to active voice
	#   converted => convert

    s/\b($nvow\S\S+)ed\b/$1/igo;


	#   cally => cly

    s/cally\b/cly/g;

	#   shorten comparision: bigger
	#   We can't deduce quicker --> quick, becasue further on
	#   the work would be converted quick --> qck. Not good any more.

    s/\b($nvow+\S+e)r\b/$1/ogi;
    $debug and warn $tab,"[comparis]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	leaning --> leang

    s/ing\b/ng/ig;
    s/io\b/o/ig;

	#	uniqe	    --> uniq

    $debug and warn $tab,"[-io]\t\t[$ARG]" if $orig =~ /$debugRegexp/;

	#   Watch out "due to"

    s/(\S\S)ue(ness?)?\b/$1/ig;

	#	authenticate -> authentic
	#	Watch out 'state' !

    s/(\S\S\S)ate\b/$1/ig;

    $debug and warn $tab,"[-ate]\t\t[$ARG]" if $orig =~ /$debugRegexp/;

    # .................................................. &heuristics ...

    $debug and warn $tab,"[0]\t\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	Vocal only at the beginning and end ==> drop last
	#	info	=> inf
	#
	#	Don't touch away

    s/\b($vow+$nvow$nvow)$vow+\b/$1/ogi;
    $debug and warn $tab,"[vowel-last]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	only one vowel in string
	#	help ==> hlp
	#	stat		BUT can't deduce to stt

    s/\b($nvow)$vow($nvow$nvow)\b/$1$2/ogi;
    $debug and warn $tab,"[vowel-one]\t[$ARG]" if $orig =~ /$debugRegexp/;


	#	asked --> skd

    s/\b($vow+$nvow$nvow)$vow($nvow)\b/$1$2/ogi;
    $debug and warn $tab,"[vowel-two]\t[$ARG]" if $orig =~ /$debugRegexp/;


	#	Delete two vowels; through --> thrgh
	#	Don't touch words ending to -ly: diffrently, difly

    s/\b($nvow+)$vow$vow($nvow$nvow+)(?!y)\b/$1$2/ogi;
    $debug and warn $tab,"[vowel-many]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	type => typ

    s/\b($nvow+$vow$nvow+(?!y))$vow\b/$1/ogi;
    $debug and warn $tab,"[vowel-end]\t[$ARG]" if $orig =~ /$debugRegexp/;


	#	many vowels, remove first two
	#	detected    => dtcted
	#	service	    => srvce

    s/\b(\S+)$vow+($nvow+)$vow+(\S*$vow\S*)\b/$1$2$3/ogi;
    $debug and warn $tab,"[vowel-more]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	Two consequent vowels
	#	obtain	    => obtan

    s/\b(\S*$vow$nvow+$vow)$vow(\S+)\b/$1$2/ogi;
    $debug and warn $tab,"[vowel-22more]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	Two non-vowels at the end
	#	contact	    => contac

#    s/($nvow)$nvow\b/$1/ogi;
#   $debug and warn $tab,"[non-vowel-2end][$ARG]" if $orig =~ /$debugRegexp/;


	#	Two same vowels
	#	took	    => tok
	#	keep	    => kep

    s/\b(\S+)($vow)\2(\S+)\b/$1$2$3/ogi;
    $debug and warn $tab,"[vowel-2same]\t[$ARG]" if $orig =~ /$debugRegexp/;

    # .................................................... &suffixes ...

    #	frequency   => freq
    #	acceptance  => accept
    #	distance    => dist

    s/u?[ae]nc[ye]\b//ig;

	#	management	=> manag
	#	establishement	=> establish

    s/ement\b/nt/ig;

        #	allocation => allocan

    s/[a-z]ion\b/n/ig;

	#	hesitate --> hesit

    s/tate\b/t/ig;

    # ................................................. &multi-chars ...

    s/ph\b//g;			# paragraph --> paragra
    s/ph/f/g;			# photograph --> fotogra

    $debug and warn $tab,"[multi]\t[$ARG]" if $orig =~ /$debugRegexp/;

    # .................................................. simple rules ...

    s/([0-9])(st|nd|th)/$1/ig;  # get rid of 1st 2nd ...

    s/\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]+\b/$1/ig;


	#	"This is the end. And new sentence."
	#	We can leave out the period.

    s/\.\s+([A-Z])/$1/g;


	#	Any line starting that does not start with aphanumeric can be
	#	deleted. Like
	#
	#	    Well, this is
	#
	#	is previously shortened to ", this is" and the leading is now
	#	shortened to
	#
	#	    this is

    s/^\s*[.,;:]\s*//;
    s/\s*\W+$/\n/;	# ending similarly.

    $debug and warn $tab,"[shorthand]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	we don't need these,

    s/[!#\$'\"*|\\^]//g;		# dummy "' to restore Emacs font-lock

	#	carefully => carefuly
	#	Don't touch 'all'

    s/([flkpsy])\1\B/$1/ig;		# Any double char to one char

    $debug and warn $tab,"[double]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#   Any double chars at the END of work

    s/\b(\S*$vow\S*)([^0-9])\2\b/$1$2/i;

    $debug and warn $tab,"[double-end]\t[$ARG]" if $orig =~ /$debugRegexp/;

	#	short => shor

    s/\rt\b/r/ig;		# Any double char to one char

    $debug and warn $tab,"[rt]\t[$ARG]" if $orig =~ /$debugRegexp/;


    # .................................................... &optimize ...

    if ( $SQZ_OPTIMIZE_LEVEL )
    {
	s/\s+(.)/\U$1/g;	# kill empty spaces
    }


    $ARG;
}


# This section is automatically updated by function
# TinyPerl.el::tiperl-selfstubber-stubs. Do not touch the BEGIN END tokens.

# BEGIN: Devel::SelfStubber


sub Squeeze::SqueezeHashSet ($;$);
sub Squeeze::SqueezeControl (;$);
sub Squeeze::SqueezeDebug (;$$);

# END: Devel::SelfStubber

1;
__DATA__

#  -- A U T O L O A D  -- A U T O L O A D  -- A U T O L O A D  --


# **********************************************************************
#
#   PUBLIC FUNCTION
#
# **********************************************************************

=pod

=over 4

=head2 new()

=item Description

Return class object.

=item Return values

object.

=back

=cut

sub new
{
     my $pkg   = shift;
     my $type  = ref($pkg) || $pkg;

     my $this  = {};
     bless $this, $type;

     $this;
}


# **********************************************************************
#
#   PUBLIC FUNCTION
#
# *********************************************************************

=pod

=over 4

=head2 SqueezeHashSet($;$)

=item Description

Set hash tables to use for converting text. The multiple word conversion
is done first and after that the single words conversions.

=item arg1: \%wordHashRef

Pointer to be used to convert single words.
If "reset", use default hash table.


=item arg2: \%multiHashRef [optional]

pointer to be used to convert multiple words.
If "reset", use default hash table.

=item Return values

None.

=back

=cut

sub SqueezeHashSet ($;$)
{
    my	  $id	= "$LIB.SqueezeHashSet";
    my( $wordHashRef, $multiHashRef ) = @ARG;

    if ( $wordHashRef eq 'reset' or $wordHashRef eq 'default' )
    {
	%wordXlate  = %SQZ_WXLATE_HASH_MAX;
    }
    elsif ( defined %$wordHashRef )
    {
	%wordXlate  = %$wordHashRef;
    }
    else
    {
	confess "$id: ARG1 must be a hash reference";
    }


    if ( defined $multiHashRef )
    {

	if (  $multiHashRef eq 'reset' or $multiHashRef eq 'default'  )
	{
	    %multiWordXlate = %SQZ_WXLATE_MULTI_HASH;
	}
	elsif ( defined %$multiHashRef )
	{
	    %multiWordXlate = %$multiHashRef;
	}
	else
	{
	    confess "$id: ARG2 must be a hash reference";
	}
    }
}


# **********************************************************************
#
#   PUBLIC FUNCTION
#
# *********************************************************************

=pod

=over 4

=head2 SqueezeControl(;$)

=item Description

Select level of text squeezing: noconv, enable, medium, maximum.

=item arg1: $state

String. If nothing, set maximum squeeze level (kinda: restore defualts).

    noconv	Turn off squeeze
    conv	Turn on squeeze
    med		Set squeezing level to medium
    max		Set squeezing level to maximum

=item Return values

None.

=back

=cut

sub SqueezeControl (;$)
{
    my	$id	= "$LIB.SqueezeControl";

    $STATE	= shift;
    $STATE	= "max"   if not defined $STATE;

    if ( $STATE eq '' or $STATE =~ /^max/i  )
    {
	SqueezeHashSet "reset", "reset";
    }
    elsif ( $STATE =~ /^med/i )
    {
	SqueezeHashSet	\%SQZ_WXLATE_HASH_MEDIUM ,
			\%SQZ_WXLATE_MULTI_HASH_MEDIUM;
    }
    elsif ( $STATE =~ /^(conv|noconv|max)/i )
    {
	# do nothing
    }
    else
    {
	confess "$id: Unknown ARG";
    }

}


# **********************************************************************
#
#   PUBLIC FUNCTION
#
# *********************************************************************

=pod

=over 4

=head2 SqueezeDebug(;$$)

=item Description

Activate or deactivate debug.

=item arg1: $state [optional]

If not given, turn debug off. If non-zero, turn debug on.
You must also supply C<regexp> if you turn on debug, unless you have
given it previously.

=item arg1: $regexp [optional]

If given, use regexp to trigger debug output when debug is on.

=item Return values

None.

=back

=cut

sub SqueezeDebug (;$$)
{
    my	$id = "$LIB.SqueezeDebug";
    my ( $state, $regexp ) = @ARG;

    $debug  = $state;
    defined $regexp and $debugRegexp = $regexp;
}

# **********************************************************************
#
#   POD FOOTER
#
# *********************************************************************

=pod

=for html
</BLOCKQUOTE>

=head1 AVAILABILITY

Author can be reached at jari.aalto@poboxes.com HomePage via forwarding
service is at http://www.netforward.com/poboxes/?jari.aalto or
alternatively absolute url is at ftp://cs.uta.fi/pub/ssjaaa/ but this may
move without notice. Prefer keeping the forwarding service link in your
bookmark.

Latest version of this module can be found at $CPAN/modules/by-module/Lingua/

=head1 AUTHOR

Copyright (C) 1998-1999 Jari Aalto. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself or in terms of Gnu General Public licence v2 or later.

=cut

__END__

# end of file Squeeze.pm
