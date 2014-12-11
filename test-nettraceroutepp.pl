#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Net::Traceroute::PurePerl;

if ($#ARGV == -1) {
   exit;
    };
my $host = $ARGV[0];

my $t = new Net::Traceroute::PurePerl(
     backend        => 'PurePerl', # this optional
     host           => $host,
     debug          => 0,
     max_ttl        => 30,
     query_timeout  => 2,
     packetlen      => 40,
     protocol       => 'icmp', # Or icmp
);
$t->traceroute;
#say $t->stat;
#say $t->found;
#say $t->pathmtu;
#say $t->hops;
$t->pretty_print;
