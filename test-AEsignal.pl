#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;

my $cv = AnyEvent->condvar;

my $count = 0;

# PIDを表示
print "PID $$ \n";

# kill -1 'PID'を１０回で終了する。
my $w = AnyEvent->signal(
	signal => 'HUP',
	cb => sub {
	    $count++;
        print "event $count\n";
        if ( $count >= 10 ) {
            $cv->send;
             }

	    }
	);

my $t = AnyEvent->timer(
	after => 10,
	interval => 10,
	cb => sub {

	print "10sec past.\n";
	}
	);


    $cv->recv;

