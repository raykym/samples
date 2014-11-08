#!/opt/lampp/bin/perl

use strict;
use warnings;

use Parallel::Benchmark;
use Furl;

	my $bm = Parallel::Benchmark->new(
	   setup => sub {
		my ($self) = @_;
		$self->stash->{ua} = Furl->new;
		},
	   benchmark => sub {
		my ($self,$id) = @_;
	        my $ua = $self->stash->{ua};
		my $sub_score = 0;
		if ($id == 1){
			my $res = $ua->post(
				"http://localhost:8080/cgiapplication/cgiapp.cgi",
				[],[ rm => 'input_finish', title => 'test program', text_field => 'test program writte' ]
			);
			$sub_score++ if $res->is_success;
		}
		else {
		    for my $path (qw/ list_testdata view / ) {
			my $res = $ua->get("http://localhost:8080/cgiapplication/cgiapp.cgi?rm=$path");
			$sub_score++ if $res->is_success;
		    }
		}
		return $sub_score;
		},
		teardown => sub {
			my ($self) = @_;
			delete $self->stash->{ua};
		},
		concurrency => 50,
		time => 60,
		);
		$bm->run;
