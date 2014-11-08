#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

if ($#ARGV == -1) { 
     say "Usage: multi_searchnet.pl [count]";
     exit;
     };

for (1..$ARGV[0]){
    system('/var/www/html/work/searchnet.pl > /dev/null 2>&1 & ');
    };



