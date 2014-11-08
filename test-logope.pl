#!/usr/bin/env perl

# access.logの更新をチェックする

use strict;
use warnings;
use feature 'say';

open (INLOG, "/var/log/apache2/access.log");

my $line;

my $oldtime = "31/Oct/2014:13:19:45";

my @loglist = <INLOG>;
my $count=0;

foreach my $i (@loglist){
       $count++;
    if ($i =~ /$oldtime/) {
       say "$i";
       last;
       };
    };

    say "$count";

#foreach my $j ($count .. $#loglist) {
#
#       #my @clms = split (/ /,$loglist[$j]);
#       #空白でsplitするとカラムが細切れになってしまう。
#       say "$loglist[$j]";
#       #say "$clms[3]"; #日付を取れる 
#       };

close( INLOG );
