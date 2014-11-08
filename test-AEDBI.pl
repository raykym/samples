#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use DBI;
use AnyEvent;
use Date::Format;
use Time::Local;
use DDP;

$| = 1;

# DB初期設定、日付更新で更新するためにサブルーチン化
sub dbsetting {
    # 日付取得 起動時、イベント検知タイミングで更新する必要がある。
    my $datestr = time2str("%Y%m%d%H%M",time);
    my $tblname = "T_".$datestr."_tbl";
    say "tblname: $tblname";

    #DB準備設定
    say "DB Connect";

    my $dbname = 'apachelog';
    my $dbuser = 'apachelog';
    my $dbpass = 'apachelogpass';

    my $db = DBI->connect("dbi:mysql:dbname=$dbname;host=192.168.0.8;port=3306","$dbuser","$dbpass", {RaiseError=>0, AutoCommit=>1,mysql_enable_utf8=>1});

    #Table作成
    my $sql_1 ="CREATE TABLE IF NOT EXISTS $tblname(`line` int(10) NOT NULL AUTO_INCREMENT, `logline` text NOT NULL, PRIMARY KEY (`line`) ) engine = InnoDB";
    my $sth_1 = $db->prepare($sql_1);

    # log insert
    my $sql_2 ="INSERT INTO $tblname (logline) VALUES(?)";
    my $sth_2 = $db->prepare($sql_2);

    # last line get
    my $sql_3 ="SELECT logline FROM $tblname order by line DESC LIMIT 1";
    my $sth_3 = $db->prepare($sql_3);

    return ($sth_1, $sth_2, $sth_3);
    }

# DB初期設定取得
my ($sth_1,$sth_2, $sth_3) = dbsetting();
say "DB setting";

# 日付テーブルの作成（無ければ）
$sth_1->execute;
say "Make Table if not exists";


sub spancalc {
    # 日付更新の計算
    my $ythis = time2str("%Y",time);
    my $mthis = time2str("%m",time);
    my $dthis = time2str("%d",time);
    my $hthis = time2str("%H",time);
    my $mithis = time2str("%M",time);

    # 日付変更のepoc time 月は-1で指定する TEST用1分で更新
    my $dayline = timelocal( 0, $mithis+1, $hthis, $dthis, $mthis-1, $ythis);

    my $span = $dayline-time; #今日の終わるまでの秒数

    say "Date check";
    return $span;
    }

# 日付更新期間の取得
my $span = spancalc();
say "span: $span";

my $stat = 1; #無限ループ用フラグ

# イベントループ
    my $cvout = AnyEvent->condvar;

    my $w = AnyEvent->signal(
        signal => "TERM",
        cb => sub {
              $stat = 0;  #whileループを止める
              $cvout->send;
              });

    my $timer_w = AnyEvent->timer(
        after => 5,
        interval => 5,
        cb => sub {
              $sth_2->execute("test word");
             });

        while ($stat){

                my $cv = AnyEvent->condvar;

                    #日付確認のループ
                    my $t = AnyEvent->timer(
                           after => $span,
                           interval => $span,
                           cb => sub {
                                #日付更新で$spanの変更、ログテーブルの更新
                                $span = spancalc();
                                ($sth_1, $sth_2, $sth_3) = dbsetting();

                                # 日付テーブルの作成
                                $sth_1->execute;
                                say "Make Table next !";
                                undef $w;
                                $cv->send;
                              });


                   my $w2 = AnyEvent->signal(
                        signal => "TERM",
                        cb => sub {
                             $cv->send;
                             });

               #    my $iw = AnyEvent->idle(
               #           cb => sub {
               #              p $t;
               #              $cv->send;
               #              });

                $cv->recv;
               # p $w;
               # p $t;
        };
  $cvout->recv;
# Last setting

$sth_1->finish;
$sth_2->finish;
$sth_3->finish;

