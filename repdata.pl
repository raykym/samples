#!/usr/bin/env perl

# mysqlから負荷を低くデータをコピー出来るのかを試す
# sqliteにコピーする
# sqliteのコピー済の部分を確認して、続きからコピーを行う
# 10000単位で読み出すように変更
# 1000万レコードを超えると10000行の抽出に30秒以上かかるので1行に変えてみる。
# 1行でも30秒かかるので意味がなかった。
# 1500万レコードを超えると100000一括の方が処理が早い。
# 終了処理が無いのでレコードの終わりでも終了しない。

use strict;
use warnings;
use feature 'say';

use DBI;
use AnyEvent;

#プリントバッファ抑制
$|=1;

# sqliteの設定

my $database = 'sitedata.sqlite3';
my $data_source = "dbi:SQLite:dbname=$database";
my $dbh = DBI->connect($data_source,undef,undef,{RaiseError => 0,PrintError => 0, AutoCommit =>1,});

my $create_table = "CREATE TABLE ipsearch_tbl(count , hostaddress , timestamp , icmp , http , https);";
$dbh->do($create_table);

my $insert = "INSERT INTO ipsearch_tbl (count, hostaddress, timestamp, icmp, http, https) VALUES (?,?,?,?,?,?);";
my $sth_insert = $dbh->prepare($insert);

my $last_sql = "SELECT max(timestamp),count FROM ipsearch_tbl ORDER BY timestamp";
my $last_sth = $dbh->prepare($last_sql);
   $last_sth->execute();
my $ref_last = $last_sth->fetchrow_hashref();
my $last_count = $ref_last->{count};
   $last_count++;
my $one_limit = 100000;

# プラグマ設定
   $dbh->do("PRAGMA synchronous = OFF");
   $dbh->do("PRAGMA journal_mode = memory");

# mysqlの設定
my $host = '192.168.0.8';
my $dbname = 'sitedata';
my $dbuser = 'sitedata';
my $dbpass = 'sitedatapass';

# DB接続設定
my $db = DBI->connect("dbi:mysql:dbname=$dbname;host=$host;port=3306","$dbuser","$dbpass",
        {RaiseError=>1, AutoCommit=>1,mysql_enable_utf8=>1});
my $sql_get = "SELECT count,hostaddress,timestamp,icmp,http,https FROM ipsearch_tbl order by count limit ?,?";

my $get_sth = $db->prepare($sql_get);

my $end_sql = "SELECT count FROM ipsearch_tbl order by count DESC limit 1";
my $end_sth = $db->prepare($end_sql);
   $end_sth->execute();
my $end_ref = $end_sth->fetchrow_hashref();
my $end_count = $end_ref->{count};

# countカラムを$one_limit行づつカウントアップしながら読み出し、書き込む
# 空を検出したら終了する事にする。
# TERMシグナルでも終了

my $cv = AnyEvent->condvar;

my $t = AnyEvent->timer(
        after => 1,
        interval => 1,
        cb => sub {

        $get_sth->execute($last_count,$one_limit);

        my @res;
        my $res_get = $get_sth->fetchall_arrayref(@res);

        foreach my $line (@$res_get){
            $sth_insert->execute(@$line);
            print "                                                      ";
            print "\r";
            print "@$line";
            print "\r"; 
            };
            $last_count = $last_count + $one_limit;
            if ($last_count > $end_count ) { $cv->send };     
        });

# 1行づつならOKだが、まとめるとmysqldが負荷をかけすぎる
#while($get_sth->execute($last_count,$one_limit)){
#    my $res_get = $get_sth->fetchall_arrayref(@res);
#
#    foreach my $line (@$res_get){
#        $sth_insert->execute(@$line);
#        print "                                                          ";
#        print "\r";
#        print "@$line";
#        print "\r";
#    };
#        $last_count = $last_count + $one_limit;
#  };

# TERMシグナル受信時の終了処理
my $w = AnyEvent->signal(
    signal => 'TERM',
    cb => sub {
        # タイマーを初期化して、ループを止める。
        undef $t;
        $cv->send;
        }
    );

   $cv->recv;

$last_sth->finish;
$get_sth->finish;
$sth_insert->finish;
