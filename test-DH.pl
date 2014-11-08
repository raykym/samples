#!/opt/lampp/bin/perl
use strict;
use warnings;
use Crypt::DH;sub default_dh {
     my $dh = Crypt::DH->new(
         p => 8995127215884267541995034125870655,
         g => 2
     );
     $dh->generate_keys;
     return $dh;
}
my $cdh = default_dh();
my $sdh = default_dh();
printf("[consumer] pub: %s, sec:  %s\n", $cdh->pub_key, $cdh->priv_key);
printf("[server] pub: %s, sec:  %s\n", $sdh->pub_key, $sdh->priv_key);
printf("shared secret(1): %s\n",  $cdh->compute_secret($sdh->pub_key));
printf("shared secret(2): %s\n",  $sdh->compute_secret($cdh->pub_key));
