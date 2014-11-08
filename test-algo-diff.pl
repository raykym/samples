#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Algorithm::Diff qw(diff);

my @list1 = ('aaaa', 'bbbb', 'cccc', 'dddd');
my @list2 = ('aaaa', 'bbbb', 'cccc', 'dddd', 'eeee', 'ffff');

my @diffs = diff( \@list1, \@list2 );

foreach my $line (@diffs) {
    say "$line";
    };

######??
