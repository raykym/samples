#!/opt/lampp/bin/perl

# randpageのイメージ出力だけを利用するだけの比較テスト用 

use strict;
use warnings;

use Data::Dumper;

use Parallel::Benchmark;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request::Common;
# HTTP::Protocol::https IO::Socket::SSL Net::SSLeay

	my $cookie_jar = HTTP::Cookies->new();

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
		$self->stash->{ua}->cookie_jar( $cookie_jar );
		},
	   benchmark => sub {
		my ($self) = @_;
	        my $ua = $self->stash->{ua};
		my $success = 0;

	#初回だけクッキー送信のためにHEADを使う。
#		$ua->head("https://westwind.iobb.net/randpage/randpage.cgi") if $success == 0 ;

#		my $res = $ua->post("https://westwind.iobb.net/randpage/randpage.cgi?rm=randpage",
#		[ rm => 'randpage' ]		
#				);

	        my $res = $ua->get("https://westwind.iobb.net/randpage/randimag.pl");
	        my $res1 = $ua->get("https://westwind.iobb.net/randpage/randimag.pl");
#	        my $resi1 = $ua->get("https://westwind.iobb.net/randpage/dbimag.pl");
#		$self->stash->{code}->{ $resi1->code }++ ;
#	        my $resi2 = $ua->get("https://westwind.iobb.net/randpage/dbimag.pl");
#		$self->stash->{code}->{ $resi2->code }++ ;
		$success++ if $res->is_success;

	#sleep(1);
		return $success ;

		},
		teardown => sub {
			my ($self) = @_;
			delete $self->stash->{ua};
		},
		concurrency => 30,
		time => 5,
		);
		my $result = $bm->run;

		print Dumper($result);

		
