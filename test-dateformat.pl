#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Date::Format;

my @lt = localtime(time);
say "@lt";
say ctime(time);
say asctime(@lt);

say time2str("%d/%b/%Y:%T",time); #apache2 log日付フォーマット

say time2str("%Y%m%d%H%M",time+86400);
say time2str("%Y",time+86400);
say time2str("%m",time+86400);
say time2str("%d",time+86400);

#timestamp
say time2str("%Y-%m-%d %H:%M:%S",time);
