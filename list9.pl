#!/opt/lampp/bin/perl

use strict;
use AnyEvent;

my $cv = AnyEvent->condvar( cd => sub{
	warn "executed all timers";
	});

for my $i (1..10){
	$cv->begin;
	my $w; $w = AnyEvent->timer(after => $i, cb => sub{
		warn "finished timer $i";
		undef $w;
		$cv->end;
		});
	};
 
 $cv->recv;

