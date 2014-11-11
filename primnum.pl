#!/usr/bin/env perl 

use strict;
use warnings;

my $n=0;
my $a=0;
my $b=0;

# オイラーの式を試した。
#while (  $n != 32 ) {
#    $a = $n**2+$n+41 ;
#    $b = $n**2 ;
#    print "$a   : $b    : $n**2+$n+41 \n";
#	$n++;
#	};

# 単純に自分以外で割り切れる数字が無ければ素数
my $startnum=1;
my $endnum=10000 ;
my $check_num ;

foreach my $num ( $startnum..$endnum ){

	my $flg=0;
	if ( $num == 2 ) {
			 printf ("%8d: %31b\n",$num,$num);
			 next ;
			 };
	for my $c_num ( 2..$num-1 ) {
		$check_num = $num % $c_num ;
		if ( $check_num == 0 ){ 
			$flg=0;
                        my $n61 = ($num -1) % 6;
                        my $n65 = ($num -5) % 6;
			printf ("%8d: %8d %8d %8d.count\n",$num,$n61,$n65,$c_num) if $n61 == 0;
			printf ("%8d: %8d %8d %8d.count\n",$num,$n61,$n65,$c_num) if $n65 == 0;
			last; 
			#割り切れたら素数じゃない
			 };
		   $flg=1;
		};

        if ($flg == 1 ) { 
                        my $n61 = ($num -1) % 6;
                        my $n65 = ($num -5) % 6;
			printf ("%8d: %8d %8d \n",$num,$n61,$n65);
                        undef $n61;
                        undef $n65;
			};
	};
