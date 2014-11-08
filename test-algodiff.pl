#!/usr/bin/env perl

use strict;
use warnings;
use Algorithm::Diff;

my @doc1 = qw(
    123
    345
    456
    abc
    ABC
    666
    777
    888
    999
);

my @doc2 = qw(
    123
    456
    aBc
    ABC
    555
    666
    777
    9999
    000
);

print "==================== [sdiff]\n";

my @sdiffs = Algorithm::Diff::sdiff(\@doc1, \@doc2);
foreach my $diff (@sdiffs) {
    my $op = $diff->[0];
    my $dat1 = $diff->[1];
    my $dat2 = $diff->[2];
    printf "%s %5s %5s\n", $op, $dat1, $dat2; 
}

print "==================== [diff]\n";

my @diffs = Algorithm::Diff::diff(\@doc1, \@doc2);
foreach my $chunk (@diffs) {
    foreach my $diff (@$chunk) {
        my $op = $diff->[0];
        my $num = $diff->[1];
        my $dat = $diff->[2];
        printf "%s %d %s\n", $op, $num, $dat; 
    }
    print "----------\n";
}
