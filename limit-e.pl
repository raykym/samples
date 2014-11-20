#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Math::BigFloat;
use Math::BigInt;
use DDP;

my $e = Math::BigFloat->new('1');
#my $n = Math::BigInt->new('9999');
my $n = 9999;
my $nrev = Math::BigFloat->bone();


#   $e = (1+(1/$n))**$n;

$e->bdiv($n);  # $e/$n・・・ $e=1
say $e;

$e->binc();    #1+$e
say $e;

$e->bpow($n);  # $e ** $n

open (OUT,">> ./limit-e.txt");

print OUT "$e\n\n";

close (OUT);

exit;


