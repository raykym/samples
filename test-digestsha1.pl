#!/usr/bin/env perl

use strict;
use warnings;

use Digest::SHA1;

my $sha1 = Digest::SHA1->new();
   $sha1->add($$ , time() , rand(time) );
my $res = $sha1->hexdigest();
   print "$res \n";


