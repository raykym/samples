#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use DDP;

use Geo::Coder::Google;

my $geocoder = Geo::Coder::Google->new(apiver => 3);
#my $location = $geocoder->geocode ( location => 'Hollywood and Highland, Los Angeles, CA' );
my $location = $geocoder->geocode ( location => '静岡県富士宮市万野原新田' );

#for my $i (keys $location) {
#     say "$i: $location->{$i}  ";
#    };

#for my $j (keys $location->{geometry}){
#    say "$j: $location->{geometry}->{$j}";
#   };

#p $location;

say "$location->{geometry}->{location}->{lat}";
say "$location->{geometry}->{location}->{lng}";

#print Dumper($location);
