#!/usr/bin/perl
#
#    Copyright (C) 1991 by Lutz Prechelt, Karlsruhe
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

# Author: Lutz Prechelt (prechelt@ira.uka.de),
#         23.03.91
# Change: Lutz Prechelt, 02.07.91
#
#         1997-10-14 - Jason Kelleher - Added "-i" option.
#
#
# Usage: see message at "die" below.

$infinity = 10000;

$precontext  = 2;
$postcontext = 2;
$paragraphmode    = 0;
$withlinenumber   = 0;
$withfilename     = 0;
$wrong_option     = 0;
$reversemode      = 0;
$insensitivemode  = 0;
$delimiterstring  = "-----------\n";
# $endpara = '\S.*\n';

sub showline {
  if ($withfilename != 0) {
    printf ("\"%s\"", $ARGV);
  }
  if ($withfilename != 0 && $withlinenumber != 0) {
    print ",";
  }
  if ($withlinenumber != 0) {
    printf ("%4d", $.);
  }
  if ($withfilename != 0 || $withlinenumber != 0) {
    print ": ";
  }
  print ($_[0]);
}


# Process the Options:
do {
  $something_done = 1;
  if ($ARGV[0] =~ /^-(\d+)$/) {
    $precontext = $postcontext = $1;
    shift;
  }
  elsif ($ARGV[0] =~ /^-(\d+)[\,\+\/\;](\d+)$/) {
    $precontext  = $1;
    $postcontext = $2;
    shift;
  }
  elsif ($ARGV[0] =~ /^-d$/ && $#ARGV > 0) {
    $delimiterstring = $ARGV[1];
    $delimiterstring =~ s/\\n/\n/o;
    shift; shift;
  }
  elsif ($ARGV[0] =~ /^-d(.*)$/) {
    $delimiterstring = $1;
    $delimiterstring =~ s/\\n/\n/o;
    shift;
  }
  elsif ($ARGV[0] =~ /^-p$/) {
    $paragraphmode = 1;
    shift;
  }
  elsif ($ARGV[0] =~ /^-n$/) {
    $withlinenumber = 1;
    shift;
  }
  elsif ($ARGV[0] =~ /^-h$/) {
    $withfilename = 1;
    shift;
  }
  elsif ($ARGV[0] =~ /^-v$/) {
    $reversemode = 1;
    shift;
  }
  elsif ($ARGV[0] =~ /^-i$/) {
    $insensitivemode = 1;
    shift;
  }
  elsif ($ARGV[0] =~ /^-e$/) { # end options (for expressions starting with - )
    $something_done = 0;
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
} while ($something_done);


# Usage message:
if ($#ARGV == -1 || $wrong_option) {
  die "
   Usage: cgrep [-pre[,post]] [-p] [-v] [-h] [-n] [-d string] pattern
[file...]

   cgrep is a context grep. It displays more than the one matching line for
   every match (2 before and 2 after as default).

   -3  means display 3 lines before and 3 lines after the match
   -5,12  means display 5 lines before the match and 12 lines after
   -p  means display only as much of the context as belongs to the
       current paragraph. (paragraphs bounded by empty lines)
   -v  means invert search (display nomatches)
   -i  means case insensitive search
   -h  means toggle display filename before every line
   -n  means display line number before every line
   -d  string  means use string as the output delimiter string
   pattern  is a Perl regular expression (you better quote it !)
\n";
}


if (length (@ARGV) > 1) {
  $withfilename = !$withfilename;
}


# Get the pattern and protect the delimiter.
$pat = shift;
$pat =~ s#/#\\/#g;

# Make the pattern case insensitive if option was specified.
if ( $insensitivemode ) {
    $pat = '(?i)' . $pat;
}


# current line will always be at end of array, i.e. $ary[$currentpre]
$_ = <>;
push(@ary,$_);
$currentpre = 0;


# now use @ary as a silo, shifting and pushing.
# the length of the @ary at any time is $currentpre + 1
# the current line is @ary[$currentpre], the postcontext is not held in @ary.
$seq = 0;
$lastoutput = $infinity;  #last output is infinitely many lines ago
$cur = $ary[0];       #current line
while ($cur) {  #as long as there is something to look at
  if ( $reversemode == 1 ? $cur !~ /$pat/o : $cur =~ /$pat/o ) {
    #match found
    if ($lastoutput <= $postcontext) {
      &showline ($cur);
    }
    else {
      print $delimiterstring if ($seq++ && $precontext + $postcontext > 0);
      foreach $line (@ary) {
        &showline ($line);
      }
    }
    $lastoutput = 0;
  }
  elsif (($cur !~ /\S.*\n/o && $paragraphmode == 1) || eof) {
#paragraph/file end
    for (; $currentpre >= 0; $currentpre--) {
      shift (@ary);
    }
    $lastoutput = $infinity;
    close (ARGV) if (eof);
  }
  elsif ($lastoutput <= $postcontext) {     #another line of postcontext
    &showline ($cur);
  }
  #goto next line of input:
  $lastoutput++;
  $_ = <> if $_;
  push(@ary,$_); 
  if ($currentpre < $precontext) {
    $currentpre++;
  }
  else {
    shift(@ary);
  }
  $cur = $ary[$currentpre];
}



