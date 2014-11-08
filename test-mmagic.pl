#!/opt/lampp/bin/perl

use strict;
use warnings;
use utf8;
use Encode;

use File::MMagic;

my $mm = File::MMagic->new('/opt/lampp/etc/magic') ;

my $res = $mm->checktype_filename('/opt/lampp/htdocs/pl-pg/music/02-風の果て.mp3');

print "$res \n" ;
