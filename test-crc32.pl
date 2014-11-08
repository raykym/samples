#!/opt/lampp/bin/perl

use strict;
use warnings;

use String::CRC32;

my $crc = crc32("192.168.1.1");
my $crc2 = crc32($crc);

print "$crc \n";
print "$crc2 \n";
