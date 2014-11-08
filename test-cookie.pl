#!/opt/lampp/bin/perl

# Furl::Cookiesを検証した。結果、httpOnlyが有るので正しくクッキーを受け取れない。

use strict;
use warnings;
use Time::Local;

my $month = {
        Jan =>  1,Feb =>  2,Mar =>  3,Apr =>  4,May =>  5,Jun =>  6,
        Jul =>  7,Aug =>  8,Sep =>  9,Oct => 10,Nov => 11,Dec => 12,
};


my $cookie = 'RANDPAGE=0058adf00428a725d3a9f377b145015d; path=/; expires=Wed, 16-Apr-2014 07:34:26 GMT; secure; HttpOnly';

my ($expires,$domain,$path,$secure,$key,$value);

for (split(/;/,$cookie)){
	$_ =~ s/^[\s]*//;
	if($_ =~ /domain/){
              my @tmp = split(/=/,$_);
                 $domain = $tmp[1];
		}
	if($_ =~ /path/){
                                my @tmp = split(/=/,$_);
                                $path = $tmp[1];
                        }
	if($_ =~ /expires/){
                                my @tmp = split(/=/,$_);
                                $tmp[1] =~ /([a-zA-Z]*), ([\w]*)-([\w]*)-([\w]*) ([\w]*):([\w]*):([\w]*) GMT/;
                                my ($w,$D,$M,$Y,$h,$m,$s) = ($1,$2,$3,$4,$5,$6,$7);
                                $expires = timegm($s,$m,$h,$D,$month->{$M}-1,$Y);
                        }
	if($_ !~ /expires|path|domain|secure|HttpOnly/){
                                my @tmp = split(/=/,$_);
                                $key = $tmp[0];
                                $value = $tmp[1];
                        }

	};

print "$domain \n" ;
print "$path \n" ;
print "$expires \n" ;
print "$key \n" ;
print "$value \n" ;

