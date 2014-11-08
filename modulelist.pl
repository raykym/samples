#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use ExtUtils::Installed;

my @m = ExtUtils::Installed->new->modules;

foreach (@m) {

  say "$_";

  };



