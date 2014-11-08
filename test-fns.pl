#!/usr/bin/env perl

use feature 'say';
use Filesys::Notify::Simple;
 
my $watcher = Filesys::Notify::Simple->new([ "." ]);
$watcher->wait(sub {
    for my $event (@_) {
        say "$event->{path}"; # full path of the file updated
    }
});
