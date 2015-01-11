#!/usr/bin/env perl

# AnyEvent->timerでloopを設定したバージョン。
# -HUPでの終了が調子悪い。 $wでundef($t)で解決？
# ipsearch_tblをパーティションに変更したための改変版
# p_ipsearch_tbl

# sqlite3に一時的に書き込みを行う。
# 乱数で設定した件数に達したら、sqlite3からmysqlへバルク書き込みを行う
# プロセス毎にsqlite3を持って、書き込みタイミングをずらす為に上限は乱数で決定する。
# TERMシグナルで終了時は書き戻しを済ませてsqlite3は削除する。
# 大量並列処理はできなくなるが、効率的になるかもしれない。


use strict;
use warnings;

use AnyEvent;
use Net::Ping;
use DBI;
use Time::Local;

my $table = "p_ipsearch_tbl";

# DB接続設定 ※※※bulk insertの為にautocommitは０に設定、手動でcommitする。
my $db = DBI->connect("dbi:mysql:dbname=sitedata;host=192.168.0.8;port=3306","sitedata","sitedatapass",
	{RaiseError=>1, AutoCommit=>0,mysql_enable_utf8=>1});

#カラムはcol0から。変数とは違う
my $sql = "INSERT INTO $table (col0,col1,col2,col3,timestamp,icmp,http,https) VALUES (?,?,?,?,?,?,?,?)";
my $sth_insert_m = $db->prepare($sql);

# privip_tblは変更していない為、hostaddressカラムはそのまま
my $chk_sql = "select hostaddress from privip_tbl where hostaddress = ?";
my $chk_sth = $db->prepare($chk_sql);

#sqlite設定
my $dbname = "./ipsearch.$$.sqlite3"; #プロセス番号を付加しておく
my $data_source = "dbi:SQLite:dbname=$dbname";
my $dblite = DBI->connect($data_source,undef,undef,{RaiseError => 0,PrintError => 0, AutoCommit =>1});

# テーブル作成、あればエラーになるが無視。
my $create = "CREATE TABLE ipsearch_tbl (col0 int, col1 int, col2 int, col3 int, timestamp text, icmp text, http text, https text);";

    $dblite->do($create);

my $sql_insert_l = "INSERT INTO ipsearch_tbl(col0, col1, col2, col3, timestamp, icmp,http,https) VALUES (?,?,?,?,?,?,?,?);";
my $sth_insert_l = $dblite->prepare($sql_insert_l);

my $sql_select_l = "select col0, col1, col2, col3, timestamp, icmp, http, https from ipsearch_tbl;";

#プリントバッファの抑止
$|=1;

# ループ実行間隔 sqlite3の書き込みなのでノンストップ
my $span = 3;

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

# バルク件数の設定（乱数）
sub makerand {
    return rand(500)+500; #500を基準に並列実行時に同時をできるだけ避けるように
    }
my $bcount = makerand();
   $bcount = int($bcount);

sub timestamp2date {
    my $timestamp = shift;
    my ($sec, $min, $hour, $day, $mon, $year) = localtime($timestamp);
    return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year + 1900, $mon + 1, $day, $hour, $min, $sec);
}


# check処理はサブルーチン化 タイマーループが見易い程度の変更
sub ipcheck {

# ランダムにipアドレスを作成 (Class D以降 224.0.0.0〜は除外する）

  $col1 = rand(224);
  $col2 = rand(255);
  $col3 = rand(255);
  $col4 = rand(255);

 #文字から数字へ
  $col1 = int($col1);
  $col2 = int($col2);
  $col3 = int($col3);
  $col4 = int($col4);

my $host = "$col1.$col2.$col3.$col4";

# プライベートアドレスチェック 面倒だがcheckは$hostを利用
   $chk_sth->execute($host) or die "ERROR:". $chk_sth->errstr;
my $chk_res = $chk_sth->rows;
   $chk_res = 1 if $col1 == 0;  # $col1が0ならパスする為

# chk_resが0ならばチェックを実行 
if ($chk_res == '0') {

    my $res1 = $p1->ping($host,1);
    my $res2 = $p2->ping($host,1);
    my $res3 = $p3->ping($host,1);

    do { $res1 = "undef" } unless ( defined($res1));
    do { $res2 = "undef" } unless ( defined($res2));
    do { $res3 = "undef" } unless ( defined($res3));

    my $timestamp = &timestamp2date(time);

    # sqlite3への書き込み 変数は$col1だがカラムはcol0から
        $sth_insert_l->execute($col1,$col2,$col3,$col4,$timestamp,$res1,$res2,$res3) or die "Error: " . $sth_insert_l->errstr;

    #同じ位置で表示されるように空白で消してから表示
    print "                                         ";
    print "\r";
    print "$host [$res1] [$res2] [$res3] :$bcount";
    print "\r";
    } else {

    #プライベープライベートアドレスの場合
    print "                              ";
    print "\r";
    print "$host PASS";
    print "\r";

    }; #check_else

}; #ipcheck


sub bulkinsert {
    my $getlist = $dblite->selectall_arrayref($sql_select_l);
    foreach my $line (@$getlist){
       $sth_insert_m->execute(@$line); 
    }
    $db->commit;
    # 書き込みが終わればテーブルを削除する
    $dblite->do("delete from ipsearch_tbl;");
   }

my $stat = 1; #無限ループ用

# イベントループ開始

while ($stat){
my $cv = AnyEvent->condvar;


my $t1 = AnyEvent->timer(
    after => 1,
    interval => $span,
    cb => sub {
	ipcheck;
        $bcount--;
        if ($bcount == 0) {
              bulkinsert(); 
              $bcount = makerand();
              $bcount = int($bcount);
              $cv->send;
             }
        });
# AnyEvent->timerの終了



# TERMシグナル受信時の終了処理
my $w = AnyEvent->signal(
    signal => 'TERM',
    cb => sub {
	# タイマーを初期化して、ループを止める。
	#undef $t1;
        $stat = 0; #無限ループ終了
        $cv->send;
        }
    );


# イベントループの終わり
    $cv->recv;

}; #whileループ用

bulkinsert(); 
system("rm -rf $dbname");

$sth_insert_m->finish;
$chk_sth->finish;
$sth_insert_l->finish;
