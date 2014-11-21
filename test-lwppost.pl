#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Encode;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

my $url = "http://192.168.0.5:3000/data_tbl";

my %params = (
    data => 'testdata',
    );

my $request = POST($url,[%params]);
#$request->referer($request);

my $ua = LWP::UserAgent->new;
   $ua->timeout(30);
   $ua->agent('Mozilla');

my $response = $ua->request($request);

   print $response->status_line, "\n";
