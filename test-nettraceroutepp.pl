#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Net::Traceroute::PurePerl;

my $t = new Net::Traceroute::PurePerl(
     backend        => 'PurePerl', # this optional
     host           => 'www.openreach.com',
     debug          => 0,
     max_ttl        => 30,
     query_timeout  => 2,
     packetlen      => 40,
     protocol       => 'udp', # Or icmp
);
$t->traceroute;
say $t->stat;
say $t->found;
#say $t->pathmtu;
say $t->hops;
$t->pretty_print;
