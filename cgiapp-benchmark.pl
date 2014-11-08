#!/opt/lampp/bin/perl

#cgiappを利用して、セッションIDのオーバーブローを確認する。セッション機能の確認。

use strict;
use warnings;

use Data::Dumper;

use Parallel::Benchmark;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request::Common;
# HTTP::Protocol::https IO::Socket::SSL Net::SSLeay

   # Cookie関係を停止
   ###	my $cookie_jar = HTTP::Cookies->new();

	my $bm = Parallel::Benchmark->new(
	   setup => sub {
		my ($self) = @_;
		$self->stash->{ua} = LWP::UserAgent->new(
			ssl_opts => {
				verify_hostname => 1,
				SSL_use_cert => 0,
				SSL_ca_file => '/opt/lampp/etc/ssl.crt/server.crt',
				SSL_key_file => {
					'westwind.iobb.net' => '/opt/lampp/etc/ssl.key/server.key',
					},
				SSL_cert_file => {
					'westwind.iob.net' => '/opt/lampp/etc/ssl.crt/server.crt'
					},
				}

				);
	###	$self->stash->{ua}->cookie_jar( $cookie_jar );
		},
	   benchmark => sub {
		my ($self) = @_;
	        my $ua = $self->stash->{ua};
		my $success = 0;

	#初回だけクッキー送信のためにHEADを使う。（今回は除外する）
	#	$ua->head("https://westwind.iobb.net/cgiapplication/cgiapp.cgi") if $success == 0 ;

		my $res = $ua->post("https://westwind.iobb.net/cgiapplication/cgiapp.cgi?rm=view",
		[ rm => 'view' ]		
				);

		$self->stash->{code}->{ $res->code }++ ;
	      # my $resi1 = $ua->get("https://westwind.iobb.net/randpage/dbimag.pl");
	#	$self->stash->{code}->{ $resi1->code }++ ;
	#       my $resi2 = $ua->get("https://westwind.iobb.net/randpage/dbimag.pl");
	# 	$self->stash->{code}->{ $resi2->code }++ ;
		$success++ if $res->is_success;

	#sleep(1);
		return $success ;

		},
		teardown => sub {
			my ($self) = @_;
			delete $self->stash->{ua};
		},
		concurrency => 10,
		time => 600,
		);
		my $result = $bm->run;

		print Dumper($result);

		
