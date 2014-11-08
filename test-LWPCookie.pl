#!/opt/lampp/bin/perl

use strict;
use warnings;

#use IO::Socket::SSL qw/SSL_VERIFY_NONE/ ;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request::Common;

use Data::Dumper;

    my $cookie_jar = HTTP::Cookies->new();
    my $ua = LWP::UserAgent->new(
			ssl_opts => {
				verify_hostname => 1,
				SSL_use_cert => 0,
                        SSL_ca_file => '/opt/lampp/etc/ssl.crt/server.crt',
                        SSL_key_file => {
                                'westwind.iobb.net' => '/opt/lampp/etc/ssl.key/server.key',
                                },
                        SSL_cert_file => {
                                'westwind.iobb.net' => '/opt/lampp/etc/ssl.crt/server.crt'
                                }, 
				});
       $ua->cookie_jar( $cookie_jar );

    my $url = 'https://westwind.iobb.net/randpage/randpage.cgi?rm=randpage';
       $ua->head($url);   #イメージ登録用にcookieを返す
    my $res = $ua->get($url);

    my $url2 = 'https://westwind.iobb.net/randpage/dbimag.pl' ;
       $ua->get($url2);

    print $res->content;

    print Dumper($cookie_jar);

