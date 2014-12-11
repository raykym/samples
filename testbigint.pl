#!/usr/bin/env perl

# 単純な使い方を試してみた。

use strict;
use warnings;

use Math::BigInt;
use Math::BigFloat;

my $n = 1000;

my $a = 5 ** $n ;

my $a_big = Math::BigInt->new('5');

my $res = $a_big ** $n ;

print "$a   :Common \n";
print "$res   :BigInt \n";

my $b_big = Math::BigFloat->new('10');
my $res_float = $b_big / 70 ;

print "$res_float  :BigFloat \n";

