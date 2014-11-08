#!/opt/lampp/bin/perl

# CPAN module loop install
# cpan_install.pl < list_file

use strict;
use warnings;
use CPAN;

my @mod ;

while ( <STDIN> ) {
	chomp $_ ;
	push(@mod,"$_") ;
	};
#print @mod ;

    foreach my $i (@mod){
	CPAN::Shell->install($i);
	#print "$i\n";
		};

