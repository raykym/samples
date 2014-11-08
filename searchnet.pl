#!/usr/bin/env perl

# AnyEvent->timerでloopを設定したバージョン。
# -HUPでの終了が調子悪い。 $wでundef($t)で解決？


use strict;
use warnings;

use AnyEvent;
use Net::Ping;
use Data::Random qw(rand_chars);
use DBI;

# DB接続設定
my $db = DBI->connect("dbi:mysql:dbname=sitedata;host=192.168.0.8;port=3306","sitedata","sitedatapass",
	{RaiseError=>0, AutoCommit=>1,mysql_enable_utf8=>1});

my $sql = "INSERT INTO ipsearch_tbl(hostaddress,icmp,http,https) VALUES (?,?,?,?)";
my $sth = $db->prepare($sql);

my $chk_sql = "select hostaddress from privip_tbl where hostaddress = ?";
my $chk_sth = $db->prepare($chk_sql);

#プリントバッファの抑止
$|=1;

# 終了用PIDの表示
print "PID $$ call kill $$\n";

my ($col1, $col2, $col3, $col4);

# Net::Pingの初期設定
my $p1 = Net::Ping->new("icmp");
my $p2 = Net::Ping->new("tcp",1);
   $p2->port_number("80");
my $p3 = Net::Ping->new("tcp",1);
   $p3->port_number("443");

my $myaddr = "192.168.0.8";
   $p1->bind($myaddr);
   $p2->bind($myaddr);
   $p3->bind($myaddr);

# check処理はサブルーチン化 タイマーループが見易い程度の変更
sub ipcheck {

# ランダムにipアドレスを作成 (Class D以降 224.0.0.0〜は除外する）

  do{ $col1 = rand_chars(set=>'numeric', min=>1, max=>3 )} until ($col1 < 224);
  do{ $col2 = rand_chars(set=>'numeric', min=>1, max=>3 )} until ($col2 < 255);
  do{ $col3 = rand_chars(set=>'numeric', min=>1, max=>3 )} until ($col3 < 255);
  do{ $col4 = rand_chars(set=>'numeric', min=>1, max=>3 )} until ($col4 < 255);

 #文字から数字へ
  $col1 = int($col1);
  $col2 = int($col2);
  $col3 = int($col3);
  $col4 = int($col4);

my $host = "$col1.$col2.$col3.$col4";

# プライベートアドレスチェック
   $chk_sth->execute($host);
my $chk_res = $chk_sth->rows;

# chk_resが0ならばチェックを実行 
if ($chk_res == '0') {

    my $res1 = $p1->ping($host,1);
    my $res2 = $p2->ping($host,1);
    my $res3 = $p3->ping($host,1);

    do { $res1 = "undef" } unless ( defined($res1));
    do { $res2 = "undef" } unless ( defined($res2));
    do { $res3 = "undef" } unless ( defined($res3));

    # DBへの書き込み
        $sth->execute($host,$res1,$res2,$res3);

    #同じ位置で表示されるように空白で消してから表示
    print "                              ";
    print "\r";
    print "$host [$res1] [$res2] [$res3]";
    print "\r";
    } else {

    #プライベープライベートアドレスの場合
    print "                              ";
    print "\r";
    print "$host PASS";
    print "\r";

    }; #check_else

}; #ipcheck




# イベントループ開始
my $cv = AnyEvent->condvar;


my $t1 = AnyEvent->timer(
    after => 2,
    interval => 2,
    cb => sub {
	ipcheck;
        }
    );
# AnyEvent->timerの終了



# TERMシグナル受信時の終了処理
my $w = AnyEvent->signal(
    signal => 'TERM',
    cb => sub {
	# タイマーを初期化して、ループを止める。
	undef $t1;
        $cv->send;
        }
    );


# イベントループの終わり
    $cv->recv;

$sth->finish;
$chk_sth->finish;
