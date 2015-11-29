#!/usr/bin/perl

    $lower = shift;
    $upper = shift;
    $random = int(rand( $upper-$lower+1 ) ) + $lower; 
    print $random,"\n"; 

