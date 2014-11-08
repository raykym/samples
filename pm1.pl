#!/opt/lampp/bin/perl

# コピーしてきたが、もともとのパッケージが存在しないので、そのままでは使えなかった。

use Math::GMPz ;
$| = 1;
$expr = $ARGV[0];  #expression
$expr =~ s/\^/**/g;  #translate power operators
$n0 = eval('use Math::GMPz qw(:constants);' . $expr);
print "$n0\n";
$t = time();
@p = ();  #prime factors
@c = ();  #composite factors
probab_prime_p($n0, 10) ? push(@p, $n0) : push(@c, $n0);
while (@c) {
  print '= ' . (@p ? join(' * ', sort { $a <=> $b } @p) . ' * ' : '') .
    '[' . join('] * [', sort { $a <=> $b } @c) . "]\n";
  $n = shift(@c);
  $m = mpz(3);
  for ($p = mpz(2); !divisible_p($n, $f = $p); $p = nextprime($p)) {
    $f *= $f while ($f < 1000);
    $m = powm($m, $f, $n);
    $f = gcd($n, $m - 1);
    $f > 1 && $f < $n and last;
  }
  probab_prime_p($f, 10) ? push(@p, $f) : push(@c, $f);
  if ($f < $n) {
    $f = $n / $f;
    probab_prime_p($f, 10) ? push(@p, $f) : push(@c, $f);
  }
}
print '= ' . join(' * ', sort { $a <=> $b } @p) . "\n";
print ((time() - $t) . " sec.\n");
