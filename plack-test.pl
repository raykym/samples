#!/opt/lampp/bin/perl

use strict;
use warnings;
use utf8;
use Encode ;

#	my $dec = decode_utf8('П');
	my $dec = decode_utf8('あ');
#	my $dec2 = decode_utf8('À');
	my $dec2 = decode_utf8('側');

print "$dec \n";
print "$dec2 \n";

#	my $edec = encode_utf8('П');
	my $edec = encode_utf8('あ');
#	my $edec2 = encode_utf8('À');
	my $edec2 = encode_utf8('側');

print "$edec \n";
print "$edec2 \n";



