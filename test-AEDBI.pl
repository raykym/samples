#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use DBI;
use Linux::Inotify2;
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

    my $db = DBI->connect("dbi:mysql:dbname=$dbname;host=192.168.0.8;port=3306","$dbuser","$dbpass", {RaiseError=>1, AutoCommit=>1,mysql_enable_utf8=>1});

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

# 監視ファイルハンドル設定
  my $fhaccesslog = new IO::File;
     $fhaccesslog->open("/var/log/apache2/access.log");

#ファイル監視設定 呼び出しはイベントループ内
sub Inotifyset {
my $inotify = new Linux::Inotify2;

   $inotify->watch ("/var/log/apache2/access.log", IN_MODIFY,
         sub {
            my $e = shift;
        #    my @loglist = <$fhaccesslog>;
        #    foreach my $line (@loglist){
        #            $sth_2->execute($line);
        #         };
        #    say "Check EVENT IN_MODIFY!!! inotify";
          #   $e->w->cancel;
    });
   return $inotify;
};

my $inotify = Inotifyset();


# 日付更新期間の取得
my $span = spancalc();
say "span: $span";

my $stat = 1; #無限ループ用フラグ


# イベントループのサブルーチン化(親プロセス)
sub Eventloop_inotify {

# イベントループ
        while ($stat){

                my $cv_inotify = AnyEvent->condvar;

                    $inotify = Inotifyset();

                    #ファイル監視のループ
                    my $inotify_w = AnyEvent->io (
                          fh => $inotify->fileno,
                          poll => 'r',
                          cb => sub {
                                my @loglist = <$fhaccesslog>;
                                foreach my $line (@loglist){
                                    $sth_2->execute($line);
                                         };
                                say "Check EVENT IN_MODIFY!!! AnyEvent-io";
                                $cv_inotify->send;
                                }
                          );

                   my $w2 = AnyEvent->signal(
                        signal => "TERM",
                        cb => sub {
                             $stat = 0;
                             $cv_inotify->send;
                             });

                $cv_inotify->recv;
                ($sth_1, $sth_2, $sth_3) = dbsetting();
        };
  return;
 }; # イベントループ閉じる


# イベントループのサブルーチン化 (子プロセス)
sub Eventloop_chngtbl {

# イベントループ
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
                                say "Make Table next co-process!";

                                $cv->send;
                              });


                   my $w2 = AnyEvent->signal(
                        signal => "TERM",
                        cb => sub {
                             $stat = 0;
                             $cv->send;
                             });

                $cv->recv;
          };
          return;
 }; # イベントループ閉じる


#フォークしてプロセスを分ける
my $pid = fork();

if ( $pid == 0 ){
    # 子プロセス 
    Eventloop_chngtbl();   

    } elsif ($pid != 0) {
    # 親プロセス
    Eventloop_inotify($pid);
    };

# Last setting

$sth_1->finish;
$sth_2->finish;
$sth_3->finish;

