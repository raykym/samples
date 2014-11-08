#!/usr/bin/env perl

use strict;
use warnings;

use Net::Traceroute;

my $tr = Net::Traceroute->new(host => "google.com");
if($tr->found) {
    my $hops = $tr->hops;
    while ($hops > 1) {
        print "Router was " .
            $tr->hop_query_host($hops, 0) . "\n";
	    $hops = $hops -1;
    }
}
