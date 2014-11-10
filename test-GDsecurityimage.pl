#!/usr/bin/env perl
# test-GDsecurityimage.pl > filename.
use strict;
use warnings;
use feature 'say';

use GD::SecurityImage;
 


# Create a normal image
my $image = GD::SecurityImage->new(
               width   => 180,
               height  => 130,
               lines   => 10,
               gd_font => 'giant',
            );
   $image->random( 'skoke char' );
  # $image->create( normal => 'rect' );
   $image->create( normal => 'blank' );
my($image_data, $mime_type, $random_number) = $image->out(force => 'jpeg' );

print $image_data;
