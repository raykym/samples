#!/opt/lampp/bin/perl 

use strict;
use warnings;

# 2に素数を足して素数であるかチェックする。
# 違う場合は次の素数になるまで繰り返し、その差を求める。
 
my $startnum;
my $endnum=1000 ;
my $check_num ;
my $num=0;
my $befor_num=3 ;

while ( $num < $endnum ){

	$num = 2 + $befor_num ;

	my $flg=0;

	for my $c_num ( 2..$num-1 ) {
		$check_num = $num % $c_num ;
		if ( $check_num == 0 ){ 
			$flg=0;
			printf ("%8d no match %8d\n",$num,$befor_num);

                        $befor_num = $num ;
			last; 
			#割り切れたら素数じゃない
			 };
		   $flg=1;
		};

        if ($flg == 1 ) { 
			printf ("%8d\n",$num);
			};
       $befor_num = $num ;
	};
