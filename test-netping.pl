#!/usr/bin/perl

use Net::Ping;

my $p1 = Net::Ping->new("icmp");

# service check
my $p2 = Net::Ping->new("tcp",2);
   $p2->port_number("80");

my $host = "westwind.iobb.net";
#my $host = "283.79.43.200";
#my $host = "192.168.0.1";
my $myaddr = "192.168.0.8";

   $p1->bind($myaddr);
   $p2->bind($myaddr);

   my $res1 = $p1->ping($host,2) ;
   my $res2 = $p2->ping($host,2) ;

   print "$host icmp respons $res1 \n" if $res1 ;
   print "$host icmp NOT respons $res1 \n" unless $res1 ;
   print "$host http respons $res2 \n" if $res2;
   print "$host http NOT respons $res2 \n" unless $res2;

   $p1->close();
   $p2->close();

