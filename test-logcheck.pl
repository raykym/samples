#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

my @list = system ("tail -a /var/log/apache2/access.log |" ) 

   foreach my $line (@list){
    say "$line";
    };

############??????
