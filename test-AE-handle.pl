#!/usr/bin/env perl

# いまいちわからない？？？
use feature 'say';
use strict;
use warnings;

$|=1;

   use AnyEvent;
   use AnyEvent::Handle;
   use Linux::Inotify2;

   use Data::Dumper;

   # open (IN, "/var/log/apache2/aaccess.log");
   # open (OUT, "/var/log/apache2/access.log");

   my $inotify = new Linux::Inotify2;
    $inotify->watch ("/var/log/apache2/access.log",IN_MODIFY, sub {
        my $e = shift;
       # my $name = $e->fullname;
       # say "$name :time";
        $e->w->cancel;
      });


   my $cv = AnyEvent->condvar;

   my $hdl; $hdl = new AnyEvent::Handle
      fh => $inotify->fileno,
      on_error => sub {
         my ($hdl, $fatal, $msg) = @_;
         AE::log error => $msg;
         $hdl->destroy;
         $cv->send;
      };

   # send some request line
   #$hdl->push_write ("getinfo\015\012");
   #say OUT "getinfo\015\012" ;

   # read the response line
   $hdl->push_read (line => sub {
      my ($hdl, $line) = @_;
     #say "got line : $line";
      $cv->send;
   });

   # $hdl->on_read (sub {
   #     my $hdl = @_;
   #     Dumper $hdl; 
   #      });


   $cv->recv;
