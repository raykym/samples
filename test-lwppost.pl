#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Encode;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use Date::Format;

#my $url = "http://192.168.0.5:3100/data_tbl";
my $url = "http://192.168.0.8/websqlite/data_tbl";

#日付チェック
my $timestamp = time2str("%Y-%m-%d %H:%M:%S",time);

my %params = (
    data => "$timestamp: あいうえおかきくけこさしすせそ",
    );

my $request = POST($url,[%params]);
#$request->referer($request);

my $ua = LWP::UserAgent->new;
   $ua->timeout(30);
   $ua->agent('Mozilla');

my $response = $ua->request($request);

   print $response->status_line, "\n";
