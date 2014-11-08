#!/opt/lampp/bin/perl 
# 素数判定プログラムを逆にして素数以外を出力する。
use strict;
use warnings;

my $n=0;
my $a=0;
my $b=0;

# 単純に自分以外で割り切れる数字が無ければ素数
my $startnum=2;
my $endnum=100000 ;
my $check_num ;

foreach my $num ( $startnum..$endnum ){

	for my $c_num ( 2..$num-1 ) {
		$check_num = $num % $c_num ;
		if ( $check_num == 0 ){ 
                      # 偶数ならパスする。
                     if ( $c_num == 2 ) { last ; };

			printf ("%8d: %31b\n",$num,$num);
			last; 
			 };
		};
	};
