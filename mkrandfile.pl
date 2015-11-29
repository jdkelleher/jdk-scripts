#!/usr/local/bin/perl

# Just like mkfile(1M), but write out random data.

# 1999-03-26 - JDK - Genesis...
# 1999-03-29 - JDK - Speed enhancements.

use Getopt::Std;


# Process the Options:
#
$bad_argument = not getopts('nv', \%opts);
$verbose_mode = $opts{'v'};
$mk_empty_file = $opts{'n'};

#do {
#    $still_options = 1;
#
#    if ( $ARGV[0] =~ /^-n$/ ) {
#	$mk_empty_file = 1;
#	shift;
#    }
#    elsif ( $ARGV[0] =~ /^-v$/ ) {
#	$verbose_mode = 1;
#	shift;
#    }
#    elsif ( $ARGV[0] =~ /^-/ ) {
#	print "don't know option '$ARGV[0]'\n";
#	$bad_argument = 1;
#	$still_options = 0;
##	shift;
#    }
#    else {
#	$still_options = 0;
#    }
#} while ( $still_options );


# Get the file size.
#
if ( $ARGV[0] =~ /^(\d+)([kbm]?)$/ ) {
    $file_size = $1;
    if ( $2 eq 'k' ) {
	$size_increment = 1024;		# kilobytes
    }
    elsif ( $2 eq 'b' ) {
	$size_increment = 512;		# blocks
    }
    elsif ( $2 eq 'm' ) {
	$size_increment = (1024*1024);	# megabytes
    }
    $size_increment ||= 1;		# bytes
    shift;
}
else {
    print "unknown size $ARGV[0]\n";
    $bad_argument = 1;
    shift;
}


# Usage message.
#
if ( $#ARGV < 0 or $bad_argument ) {
    die "Usage: mkrandfile [-nv] <size>[g|k|b|m] <name1> [<name2>] ...\n";
}


# Get ready.
#
srand;
$file_size *= $size_increment;


# Make the files.
#
while ( @ARGV ) {

    $OutFile = shift;
    open(OUTFILE, ">$OutFile")
	or die "Can't open $OutFile,";

    if ( $mk_empty_file ) {
	seek OUTFILE, $file_size-1, 0;
	print OUTFILE "\0";
    }
    else {
	for ( $i=0; $i < int($file_size / 4); $i++ ) {
	    print OUTFILE pack("f", rand());
	}
	for ( $i=0; $i < ($file_size % 4); $i++ ) {
	    print OUTFILE pack("c", int(rand(255)+1));
	}
    }

    close(OUTFILE);

    print $OutFile, " ", $file_size, " bytes\n" if $verbose_mode;

}


