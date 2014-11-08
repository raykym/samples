#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use File::Tail;

$|=1;

my $apachelog = File::Tail->new("/var/www/html/work/test.txt");

   while (defined(my $line=$apachelog->read)) {
       say "$line";
       };

