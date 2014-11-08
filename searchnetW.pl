#!/usr/bin/env perl

# while loop版

use strict;
use warnings;

use AnyEvent;
use Net::Ping;
use Data::Random qw(rand_chars);
use DBI;

# DB接続設定
my $db = DBI->connect("dbi:mysql:dbname=sitedata","siteuser","siteuserpass",
	{RaiseError=>0, AutoCommit=>1,mysql_enable_utf8=>1});

my $sql = "INSERT INTO ipsearch_tbl(hostaddress,icmp,http) VALUES (?,?,?)";
my $sth = $db->prepare($sql);

#プリントバッファの抑止
$|=1;

# 終了用PIDの表示
print "PID $$ call kill -HUP $$\n";

my ($col1, $col2, $col3, $col4);

# Net::Pingの初期設定
my $p1 = Net::Ping->new("icmp");
my $p2 = Net::Ping->new("tcp",2);
   $p2->port_number("80");

my $myaddr = "192.168.0.8";
   $p1->bind($myaddr);
   $p2->bind($myaddr);

# イベントループ開始
my $cv = AnyEvent->condvar;


    while(1) {


# ランダムにipアドレスを作成
do { $col1 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col1 < 255);
do { $col2 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col2 < 255);
do { $col3 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col3 < 255);
do { $col4 = rand_chars(set=>'numeric', min=>1, max=>3 ) } until ($col4 < 255);

  $col1 = int($col1);
  $col2 = int($col2);
  $col3 = int($col3);
  $col4 = int($col4);

my $host = "$col1.$col2.$col3.$col4";

my $res1 = $p1->ping($host,2);
my $res2 = $p2->ping($host,2);

do { $res1 = "undef" } unless ( defined($res1));
do { $res2 = "undef" } unless ( defined($res2));

# DBへの書き込み
    $sth->execute($host,$res1,$res2);

#同じ位置で表示されるように空白で消してから表示
print "                              ";
print "\r";
print "$host [$res1] [$res2]";
print "\r";

        };
# whileの終了


# HUPシグナル受信時の終了処理
my $w = AnyEvent->signal(
    signal => 'HUP',
    cb => sub {
	#undef $w;
        $cv->send;
        }
    );


# イベントループの終わり
    $cv->recv;

$sth->finish;
