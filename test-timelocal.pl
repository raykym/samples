#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Time::Local;
use Date::Format;

   my $nowdate = localtime(time);
   say "$nowdate";

my $yafter = time2str("%Y",time+86400);#翌日の取得     
my $mafter = time2str("%m",time+86400);
my $dafter = time2str("%d",time+86400);

   say "$yafter $mafter $dafter";

   my $dayline = timelocal( 0, 0, 0, $dafter, $mafter-1, $yafter );

   my $localdayline = localtime($dayline);
   say "$localdayline";

   my $span = $dayline-time;
   say "span: $span";

