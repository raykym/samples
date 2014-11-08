#!/usr/bin/env perl

use strict;
use warnings;

use Digest::SHA3;

my $sha3 = Digest::SHA3->new();
   $sha3->add($$, time(), rand(time) );
my $res = $sha3->hexdigest();
   print "$res \n";


