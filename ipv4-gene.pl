#!/opt/lampp/bin/perl

use strict;
use warnings;

use Data::Random qw(rand_chars);

my ($col1, $col2, $col3, $col4);


do { $col1 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col1 < 255 ) ;
do { $col2 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col2 < 255 ) ;
do { $col3 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col3 < 255 ) ;
do { $col4 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col4 < 255 ) ;


print "$col1.$col2.$col3.$col4 \n";

