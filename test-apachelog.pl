#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Date::Format;

my $nowdate = time2str("%d/%b/%Y:%T",time);

open ( LOG , "/var/log/apache2/access.log");

#######
