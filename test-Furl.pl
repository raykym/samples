#!/opt/lampp/bin/perl

use strict;
use warnings;

use IO::Socket::SSL;
use Furl;
use Furl::Cookies ;
use HTTP::Request;
use HTTP::Request::Common qw/GET/ ;

use HTTP::Headers;
use HTTP::Cookies;

use Data::Dumper;


	my $furl = Furl->new(
		ssl_opts => {
	        	SSL_use_cert => 0,
			SSL_ca_file => '/opt/lampp/etc/ssl.crt/server.crt',
			SSL_key_file => {
				'westwind.iobb.net' => '/opt/lampp/etc/ssl.key/server.key',
				},
			SSL_cert_file => { 
				'westwind.iobb.net' => '/opt/lampp/etc/ssl.crt/server.crt'
				},
		},
		);

	my $cookies = HTTP::Cookies->new;
	my $h = HTTP::Headers->new;
	   $h->header('Content-Type' => 'text/Plain');

        my $req = GET('https://westwind.iobb.net/randpage/randpage.cgi?rm=randpage');
	my $hres = HTTP::Request->new(
			GET => 'https://westwind.iobb.net/randpage/randpage.cgi?rm=randpage'
			);
 print Dumper($hres); print "\n";
	$cookies->add_cookie_header($hres);
	my $res = $furl->request_with_http_request($hres)->as_http_response;
	$res = $furl->request($hres);



	print Dumper($res);
	print "---------------------------------------\n";
	print Dumper($cookies);
	#print "---------------------------------------\n";
	print Dumper($hres);
	#print "---------------------------------------\n";
	#print Dumper($req);
	#print "---------------------------------------\n";
	#print Dumper($res);

#	 $res = $furl->post(
#		'http://localhost:8080/cgiapplication/cgiapp.cgi?rm=input_finish',
#		[],
#		[ title => 'bench input'],
#		);

