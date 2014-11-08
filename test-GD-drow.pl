#!/opt/lampp/bin/perl

use strict;
use warnings;
use GD;
use GD::Text;

    my $img =new GD::Image(1000, 1000);

    my $white = $img->colorAllocate(255, 255, 255);
    my $black = $img->colorAllocate(0, 0, 0);
    my $green = $img->colorAllocate(0, 128, 0);
    my $red = $img->colorAllocate(255, 0, 0);
    my $blue = $img->colorAllocate(0, 0, 255);

       $img->transparent($white);
       $img->interlaced('true');

       $img->fill(0, 0, $black);

       $img->setPixel(100,100,$green);

       $img->line(130,100,250,100,$blue);
       $img->line(0,0,1000,1000,$green);

       $img->dashedLine( 100,130,250,130,$red);

       $img->rectangle(800,800,1000,1000,$white);

       $img->filledRectangle(800,800,600,600,$blue);

       $img->rectangle(1,1,999,999,$green);

       my $poly = new GD::Polygon;
       $poly->addPt(500,0);
       $poly->addPt(500,500);
       $poly->addPt(0,500);
       $poly->addPt(50,50);
       $poly->addPt(600,250);
       $img->openPolygon($poly,$red);
#       $img->unclosedPolygon($poly,$green);

       my $out ;
       open( $out, "> ./test-GD-drow.jpeg");
       binmode($out);
       print $out $img->jpeg();
       close($out);


