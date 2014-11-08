#!/usr/bin/env perl

use strict;
use warnings;

use Net::Whois::IP qw(whoisip_query);
use Data::Dumper;
use DDP;

my $ip = "8.8.8.8";

# my $response = whoisip_query($ip);
# foreach (sort keys(%{$response}) ) {
#           print "$_ $response->{$_} \n";
# }

#$optional_multiple_flag set to a value
my $response = whoisip_query( $ip,"true");
#foreach ( sort keys %$response ){
#          print "$_ is\n";
#          foreach ( @{ $response->{ $_ } } ) {
#                      print "  $_\n";
#          }
#};

#print Dumper($response);
p $response;
