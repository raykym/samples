#!/usr/bin/env perl

use strict;
use warnings;

use Digest::MD5;

my $md5 = Digest::MD5->new();
   $md5->add($$ , time() , rand(time) );
my $res = $md5->hexdigest();
   print "$res \n";


