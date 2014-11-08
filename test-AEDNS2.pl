#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent::DNS;
use Data::Dumper;

my @domains = qw/yahoo.co.jp/;
my $resolver = AnyEvent::DNS->new( server => '192.168.0.1' );
my %results;

### Set up the condvar
my $done = AE::cv;
$done->begin( sub { shift->send } );

for my $domain (@domains) {
  $done->begin;
  $resolver->resolve($domain, 'a', sub {push @{$results{$domain}}, \@_; $done->end;});
}

### Decrement the cv counter to cancel out the send declaration
$done->end;

### Wait for the resolver to perform all resolutions
$done->recv;

print Dumper \%results;

