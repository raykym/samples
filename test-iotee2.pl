#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use IO::Tee;
use IO::File;

$|=1;

#open (IN, "/var/log/apache2/access.log");

#my $fhin = \*IN;
my $fhout = new IO::File "/var/log/apache2/access.log","r";

while (1) {
if (defined $fhout) {
     print <$fhout>;
    # undef $fhout;
    };
};



#my $tee = new IO::Tee($fhin, $fhout);

#while (1) {

#    $tee->print($_,"\n");

#   };
