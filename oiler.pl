#!/opt/lampp/bin/perl 

use strict;
use warnings;

my $n=0;
my $a=0;

# オイラーの式を試した。
while (  $n != 35 ) {
    $a = $n**2+$n+41 ;
    print "$a   :$n \n";
	$n++;
	};

