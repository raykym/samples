#!/usr/bin/env perl

use strict;
use warnings;

use Linux::Inotify2;
use AnyEvent;
use AnyEvent::Handle;
 
#プリントバッファ抑制
$| = 1;

# create a new object
my $inotify = new Linux::Inotify2
   or die "unable to create new inotify object: $!";
 
# add watchers
$inotify->watch ("/var/log/apache2/access.log", IN_MODIFY, sub {
   my $e = shift;
   my $name = $e->fullname;
   print "$name was accessed\n" if $e->IN_ACCESS;
   print "$name was moddified\n" if $e->IN_MODIFY;
   print "$name is no longer mounted\n" if $e->IN_UNMOUNT;
   print "$name is gone\n" if $e->IN_IGNORED;
   print "events for $name have been lost\n" if $e->IN_Q_OVERFLOW;
 
   # cancel this watcher: remove no further events
  # $e->w->cancel; # コメントすると無限ループする。
});
 
# manual event loop  :::AnyEventでのループとバーター
#1 while $inotify->poll;

# signal HUPで終了
    my $cv = AnyEvent->condvar;

# integration into AnyEvent (works with EV, Glib, Tk, POE...)
my $inotify_w = AnyEvent->io (
   fh => $inotify->fileno, poll => 'r', cb => sub { $inotify->poll }
);  # $cv->sendをpollの後ろに付けていないから無限ループする

    my $w = AnyEvent->signal(
            signal => 'HUP',
            cb => sub {
            $cv->send;
            }
         );

    my $hdl = new AnyEvent::Handle fh => $inotify->fileno;
       $hdl->push_read ( line =>'\n', sub {
                my ($hdl,$line,$eol) = @_; 
                print "$line \n";
                }); 

     $cv->recv;




