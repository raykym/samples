#!/usr/bin/env perl

use strict;
use warnings;

use Math::BigInt;

my $chk_num = Math::BigInt->new();

my $chk_trag = Math::BigInt->new();
my $progre = Math::BigInt->new();

my $n = Math::BigInt->new('10000');
my $end = $n +3 ;

my $check_mod ;

while ($n != $end ) {

	# オイラーの式を当てはめて、素数かチェックする
	$chk_num = $n ** 2 + $n + 41 ;
	if ( $chk_num % 2 == 0 ) {
	    #偶数なら飛ばす
		$n++;
                next ;
		};

       my $flg=0;
       my $chk_trag = 2 ;

       while ( $chk_trag < $chk_num ) {


		$check_mod = $chk_num % $chk_trag ;
                if ( $check_mod == 0 ) {
			$flg=0;
			print "$chk_num Not! \n";
			last;
			};
		  $flg=1;
		  $chk_trag++;

        #進捗表示
		  $progre= $chk_trag * 100 / $chk_num ;
		  printf ("%s%3d%s", $chk_num, $progre, "%") ;
		  print "=" x ($progre /10 *2 );
		  print "\r" ;

		};
	 if ( $flg == 1 ){
			print " $chk_num prim! \n";
			};
	$n++
	};
