#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Ping;

my $c = AnyEvent->condvar;
 
my $ping = AnyEvent::Ping->new;
 
$ping->ping('yahoo.com', 1, sub {
    my $result = shift;
    print "Result: ", $result->[0][0],
      " in ", $result->[0][1], " seconds\n";
    $c->send;
});
 
$c->recv;
$ping->end;
