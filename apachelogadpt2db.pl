#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Linux::Inotify2;
use IO::File;
use Date::Format;
use Time::Local;
use AnyEvent;
use Proc::ProcessTable;
use DBI;

$| = 1; #プリントバッファの抑制

my $debug = "ON";
my $debuglog = "./apachelogadpt2db.log";

sub DEbuglog {
    # debugならログファイルをopen
    open ( LOG, ">>$debuglog" ) if $debug eq 'ON';
    my $lt = localtime(time);
    say LOG "[$lt] @_" if $debug eq "ON";
    close(LOG);
    return;
    };

DEbuglog "Logging Start ------------------------------";

# /var/log/apache/access.logを監視して、DBに書き出す
# テーブルは日付で作成 日付更新,forkした別プロセスで更新実行
# KNOPPIX用なので/var/logはメモリ上にあるため、再起動時に初期化される。
# cronが稼働していればこんなに面倒なプログラムは不要なのに

# DB初期設定、日付更新で更新するためにサブルーチン化
sub dbsetting {
    # 日付取得 起動時、イベント検知タイミングで更新する必要がある。
    my $datestr = time2str("%Y%m%d",time);
    my $tblname = $datestr."_tbl";
    DEbuglog "tblname: $tblname";

    #DB準備設定
    DEbuglog "DB Connect";

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


# apacheが起動しているのか確認
my $apcok = '0';
my $ptable = new Proc::ProcessTable;
   foreach my $p (@{$ptable->table}){
       if ($p->cmndline =~ /apache2/ ) {
          DEbuglog "apache2 OK";
          $apcok = 'OK';
          last;
          };
       };
DEbuglog "apache2 Not Found" if $apcok eq '0';
exit 0 if $apcok eq '0';


# DB初期設定取得
my ($sth_1,$sth_2, $sth_3) = dbsetting();
DEbuglog "DB setting finish";

# 日付テーブルの作成（無ければ）
$sth_1->execute;
DEbuglog "Make Table if not exists";

# 日付更新サブルーチン
sub spancalc {
    # 日付更新の計算
    my $yafter = time2str("%Y",time+86400);
    my $mafter = time2str("%m",time+86400);
    my $dafter = time2str("%d",time+86400);

    # 日付変更のepoc time 月は-1で指定する
    my $dayline = timelocal( 0, 0, 0, $dafter, $mafter-1, $yafter);

    my $span = $dayline-time; #今日の終わるまでの秒数

    DEbuglog "Date check";
    return $span;
    }

#ファイル監視設定 呼び出しはイベントループ内
sub Inotifyset {
my $inotify = new Linux::Inotify2;

   $inotify->watch ("/var/log/apache2/access.log", IN_MODIFY,
         sub {
            my $e = shift;
            DEbuglog "inotify setting.";
          #   $e->w->cancel;
    });
   return $inotify;
};


# 日付更新期間の取得
my $span = spancalc();
DEbuglog "span: $span";

my $stat = 1; #無限ループ用フラグ


# 監視ファイルハンドル設定
  my $fhaccesslog = new IO::File;
     $fhaccesslog->open("/var/log/apache2/access.log");

# 監視用オブジェクトを定義 main::$inotifyの為ココに
my $inotify = Inotifyset();

# inotifyイベントループ(親プロセス用)
sub Eventloop_inotify {

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
                                DEbuglog "Check EVENT IN_MODIFY!!!";
                                $cv_inotify->send;
                                }); 

                   my $w2 = AnyEvent->signal(
                        signal => "TERM",
                        cb => sub {
                             $stat = 0;
                             $cv_inotify->send;
                             });
                $cv_inotify->recv;

                #日付更新でテーブル変更を検知するために、毎度DBを再設定
                ($sth_1, $sth_2, $sth_3) = dbsetting();
        };
    return;
    };


# 日付テーブル更新イベントループ(子プロセス用)
sub Eventloop_chngtbl {

        while ($stat){
                my $cv = AnyEvent->condvar;

                    #日付確認のループ
                    my $t = AnyEvent->timer(
                           after => $span,
                           cb => sub {
                                #日付更新で$spanの変更、ログテーブルの更新
                                $span = spancalc();
                                ($sth_1, $sth_2, $sth_3) = dbsetting();

                                # 日付テーブルの作成
                                $sth_1->execute;
                                DEbuglog "Make Table next day!";

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
    };

DEbuglog "Event loop start";

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

DEbuglog "Logging End ------------------------------";



