#!/opt/lampp/bin/perl -w
use strict;
use Jcode;
 
use GD::Graph::linespoints;
 
my @labels  = qw( under 10s  20s  30s  40s  50s  60s  70s over );
my @dataset = qw(   20   40   60   80   65   15   10   20    5 );
my @data    = ( \@labels, \@dataset);
 
my $graph = GD::Graph::linespoints->new( 400, 300 );
 
$graph->set( title   => jcode("にこにこ村の人口")->utf8,
             y_label => jcode("人数")->utf8 );
 
GD::Text->font_path( "/usr/share/fonts/truetype" );
$graph->set_title_font( "fonts-japanese-gothic.ttf", 14 );
$graph->set_legend_font( "fonts-japanese-gothic.ttf", 8 );
$graph->set_x_axis_font( "fonts-japanese-gothic.ttf", 8 );
$graph->set_x_label_font( "fonts-japanese-gothic.ttf", 10 );
$graph->set_y_axis_font( "fonts-japanese-gothic.ttf", 8 );
$graph->set_y_label_font( "fonts-japanese-gothic.ttf", 8 );
 
my $image = $graph->plot( \@data );
 
open( OUT, "> graph.jpg") or die( "Cannot open file: graph.jpg" );
binmode OUT;
print OUT $image->jpeg();
close OUT;
