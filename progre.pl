#!/usr/bin/env perl

# /root/sitedata_base/sitedata.sqlite3からhostaddressの上位単位で読みだして、
# 進捗を計算する。
# 標準出力に出すので、progre.pl | tee -a ./progre.d/progreYYYYMMDD.txtで残す

# 処理高速化の為、sitedata.sqlite3をIsitedata.sqlite3にコピーして、
# hostindexを作成する。
# 集計はIsitedata.sqlite3で行う。

use strict;
use warnings;
use feature 'say';

use DBI;

#プリントバッファ抑制
$|=1;

# sitedata.sqlite3のコピー（上書き）
say "sitedata.sqlite3 coping...";
system('cp -f /root/sitedata_base/sitedata.sqlite3 ./Isitedata.sqlite3');
say "sitedata.sqlite3 copy done.";

# sqliteの設定

my $database = 'Isitedata.sqlite3';
my $data_source = "dbi:SQLite:dbname=$database";
my $dbh = DBI->connect($data_source,undef,undef,{RaiseError => 0,PrintError => 0, AutoCommit =>1,});

my $index_sql = "create index hostindex on ipsearch_tbl(hostaddress)";

my $sql = "select count(DISTINCT hostaddress) from ipsearch_tbl where hostaddress like ?";
my $count_sth = $dbh->prepare($sql);

# プラグマ設定
#   $dbh->do("PRAGMA synchronous = OFF");
   $dbh->do("PRAGMA journal_mode = memory");

# indexの作成
   say "Isitedata.sqlite3 make index...";
   $dbh->do($index_sql);
   say "Isitedata.sqlite3 make index done.";

my $likevar;

foreach my $num (1..223) {

   $likevar = "$num.%";
   print "$likevar : ";
   $count_sth->execute($likevar);
   my @res = $count_sth->fetchrow_array;
   my $res = shift @res;
   my $per = ($res / 16581375) * 100;
   say "$res $per%";
   };

$count_sth->finish;
