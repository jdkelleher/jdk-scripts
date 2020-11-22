#!/usr/bin/perl 

# read a file, strip comments, print the result 

use strict;
use warnings;


while ( <> ) {

	# C-style comments must be handled first in case one contains a # or //

	# /* ... Strip single-line C-style comments */
	s!/\*.*\*/!!g;

	# /* ... Strip mulit-line C-style comments */
	if ( s!/\*.*$!! ) {
		print;
		while ( <> ) {
			if ( s!.*\*/!! ) {
				print;
				last;
			}
		}
	}

	# // ... Strip C++-style comments
	s!//.*$!!;

	# # ...  Strip shell-style comments
	s!#.*$!!;

	print;
}


