#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

# teeコマンドのような感じ

open ( IN, "/var/log/apache2/access.log");

while (read IN my $line){
    say "$line";
    };

close (IN);
