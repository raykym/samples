#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Proc::ProcessTable;

#  A cheap and sleazy version of ps
sub psall {
my $FORMAT = "%-6s %-10s %-8s %-24s %s\n";
my $t = new Proc::ProcessTable;
 printf($FORMAT, "PID", "TTY", "STAT", "START", "COMMAND"); 
 foreach my $p ( @{$t->table} ){
   printf($FORMAT, 
          $p->pid, 
          $p->ttydev, 
          $p->state, 
          scalar(localtime($p->start)), 
          $p->cmndline);
 }
 };


 # Dump all the information in the current process table
sub dall {
my $t = new Proc::ProcessTable;

 foreach my $p (@{$t->table}) {
  print "--------------------------------\n";
  foreach my $f ($t->fields){
    print $f, ":  ", $p->{$f}, "\n";
  }
 } 
 };

# psall or dallの指定を変更する。
#psall;


my $t = new Proc::ProcessTable;

    foreach my $p (@{$t->table}) {
      
      if ($p->cmndline =~ /apache2/ ) {
         say "apache2 OK";    
         last;
         };
     };

