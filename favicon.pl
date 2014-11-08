#!/opt/lampp/bin/perl

use strict;
use warnings;
use Data::Random qw(rand_chars);

 use GD;
use GD::Text;
        my $img = new GD::Image(64,64);
        my $white = $img->colorAllocate(255, 255, 255);
        my $black = $img->colorAllocate(0, 0, 0);
        my $green = $img->colorAllocate(100, 228, 50);
        my $red = $img->colorAllocate(255, 0, 0);
        my $blue = $img->colorAllocate(0, 0, 255);

	$img->transparent($green);
	$img->interlaced('true');
	$img->fill(0, 0, $green);

        #my $dum = rand_chars (set=>'alpha',min=> 1, max=> 1);
	my $dum = "WEST";
	my $dum2 = "WIND";
	
	my $set_font = "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf" ;

#        $img->string(gdGiantFont, 50, 50, $dum ,$black );
	$img->stringFT($black, $set_font, 18, 0, 0, 25, $dum);
	$img->stringFT($black, $set_font, 18, 0, 5, 50, $dum2);

        my $out ;
        open( $out, "> ./favicon.jpeg");
        binmode($out);
        print $out $img->jpeg();
        close($out);

