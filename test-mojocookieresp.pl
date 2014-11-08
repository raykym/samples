#!/usr/bin/env perl

use Mojo::Cookie::Response;

my $cookie = Mojo::Cookie::Response->new;

   $cookie->name('foo');
   $cookie->value('bar');

   $cookie->domain('192.168.0.8');
   $cookie->httponly('true');
   $cookie->max_age(86400);
   $cookie->origin('westwind.iobb.net');
   $cookie->path('/test');
   $cookie->secure('1');
   $cookie->expires(time + 60);
 
   print "$cookie \n";

