#!/usr/bin/env perl

use strict;
use warnings;

    use IO::Tee;
    use IO::File;

    my $tee = new IO::Tee(\*STDOUT,
        new IO::File(">tt1.out"), ">tt2.out");

    print join(' ', $tee->handles), "\n";

    for (1..10) { print $tee $_, "\n" }
    for (1..10) { $tee->print($_, "\n") }
    $tee->flush;

    $tee = new IO::Tee('</etc/passwd', \*STDOUT);
    my @lines = <$tee>;
    print scalar(@lines);
