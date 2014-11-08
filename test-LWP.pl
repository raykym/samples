#!/opt/lampp/bin/perl

use strict;
use warnings;

use IO::Socket::SSL qw/SSL_VERIFY_NONE/ ;

use LWP::UserAgent;

    my $ua = LWP::UserAgent->new(
			ssl_opts => {
				verify_hostname => 1,
		# SSL_verify_mode => SSL_VERIFY_NONE,
				SSL_use_cert => 0,
                        SSL_ca_file => '/opt/lampp/etc/ssl.crt/server.crt',
                        SSL_key_file => {
                                'westwind.iobb.net' => '/opt/lampp/etc/ssl.key/server.key',
                                },
                        SSL_cert_file => {
                                'westwind.iobb.net' => '/opt/lampp/etc/ssl.crt/server.crt'
                                }, 
				});

    my $url = 'https://westwind.iobb.net/randpage/randpage.cgi?rm=randpage';
    my $res = $ua->get($url);

    print $res->content;

    print $ua->ssl_opts('verify_hostname');

