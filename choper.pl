#!/usr/local/bin/perl

# choper.pl

#
#    Copyright (C) 1991 by Jason D. Kelleher
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 1, or (at your option)
#    any later version.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    If you don't have a copy of the GNU General Public License write to
#    Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Author: Jason D. Kelleher (kelleher@eecis.udel.edu)
#
# Change:
#
# 1999-05-26 - JDK - Genesis...
# 1999-06-03 - JDK - Made it work.
# 1999-06-15 - JDK - Now handles comment delimiters.
# 1999-06-16 - JDK - Minor cleanup.
#

use Text::Wrap;


$line_1_indent = '';
$line_2_indent = '';

# Process the Options.
do {
    $something_done = 1;
    if ($ARGV[0] =~ /^-h/) {
	$help = 1;
	shift;
    }
    elsif ($ARGV[0] =~ /^-(\d+)$/) {
	$Text::Wrap::columns  = $1;
	shift;
    }
    elsif ($ARGV[0] =~ /^-/) {
	printf ("don't know option '%s'\n", $ARGV[0]);
	$wrong_option = 1;
	$something_done = 0;
	shift;
    }
    else {
	$something_done = 0;
    }
} while ( $something_done );


# Usage message.
if ( $help or $wrong_option ) {
  die "
Usage: choper [-h] [-x] [infile]
    Word wraps stdin at 70th column onto stdout 
    -x    word wrap at column x 
    -h    this help message 
\n";
}


$Text::Wrap::columns ||= 70;


# Read in whole paragraphs.
$/ = "\n\n";


while (<>) {

    # Preserve blank lines.
    if ( /^\s*$/s ) {
	print;
	next;
    }

    # Get indent for first line.
    if ( /^([ \t\n]*[;#*]?[ \t]*)/ ) {
	$line_1_indent = $1;
    }

    # Get indent for all subsequent lines.
    if ( /[^\n]+\n([ \t]*[;#*]?[ \t]*)[^\s]+/ ) {
	$line_2_indent = $1;
    }
    else {
	$line_2_indent = $line_1_indent;
    }

    # Remove comment delimiters.
    s/^[ \t]*[;#*]?[ \t]*//mg;

    # Compress white space.
    tr/ \t\r\n/ /s;

    # Two spaces after a period which looks like it ends a sentence.
    # Even if the period is inside a paren.
    s/([^A-Z]?)(\.\)?) +([^.])/$1$2  $3/gs;

    # Fix spacing after some common abbreviations.
    s/(Dr|Mr|Ms|Mrs|Miss|ie|eg|etc)\. /$1./gs;

    print wrap( $line_1_indent, $line_2_indent, $_ ), "\n\n";

}

