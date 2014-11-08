#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Linux::Inotify2 ;
use Data::Dumper;

 # create a new object
 my $inotify = new Linux::Inotify2
    or die "Unable to create new inotify object: $!" ;

 # create watch
 $inotify->watch ("/var/log/apache2/access.log", IN_MODIFY)
    or die "watch creation failed" ;

 while (1) {
   $inotify->poll;
   my @events = $inotify->read;
   unless (@events > 0) {
     print "read error: $!";
     last ;
   }
    foreach (keys @events) {

    say $_;

    };
 };
