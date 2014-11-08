#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Date::Format;
use Time::Local;
use Linux::Inotify2;
use AnyEvent;   # EV,Event,Tk,POE・・・
use Proc::ProcessTable;
use DBI;

$| = 1; #プリントバッファの抑制

my $debug = "ON";
my $debuglog = "./apachelog2db.log";


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
# テーブルは日付で作成 日付更新もタイマーで監視する。
# KNOPPIX用では/var/logはメモリ上にあるため、再起動時に初期化される。
# 高負荷では多分利用できないが、一般利用なら大丈夫だろう。
# ログで更新時刻を見ているので１秒以下の多重アクセスをダブルカウントで登録してしまう。ログの履歴は残るが、アクセス回数は保証出来ない。
# 初期はログがあったとしてもイベント発生まではDBへの登録が行われない！！！！

#!!!!!テーブル更新後、DBアクセスが引き継がれない問題、未解決！！！！！！！

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

# DB初期設定取得
my ($sth_1,$sth_2, $sth_3) = dbsetting();
DEbuglog "DB setting finish";

 
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

# 日付テーブルの作成（無ければ）
$sth_1->execute;
DEbuglog "Make Table if not exists";

sub getlastline {
    # 最終日付の取得
    $sth_3->execute;
    my $lastline = $sth_3->fetchrow_array() || '';

    my @colms = split (/ /,$lastline);
    my $lasttime = $colms[3] || '';
    # $lastlineが空白の可能性がある。
       $lasttime =~ s/\[//g; # [を除外しないとマッチでエラーになる
    DEbuglog "Take log last time. : $lasttime";
    return $lasttime ;
}


#ファイル監視の設定　ループは下記のイベントループ内で無限ループする。
    my $inotify = new Linux::Inotify2;

       $inotify->watch ("/var/log/apache2/access.log", IN_MODIFY,
                 sub {
                     my $e = shift;
                     # ログ差分の検出、DBへの登録

                     # DBからの最終日付取得
                     my $lasttime = getlastline();
                     #ログを取得
                     open (INLOG, "/var/log/apache2/access.log");
                     my @loglist = <INLOG>;
                     close (INLOG);
                     DEbuglog "Get access.log";
                    #### $lastlineが空なら別処理
                     my $count = 0; # $lastlineが空白ならパスして全部を登録する
                     if ($lasttime ne '' ) {
                         foreach my $i (@loglist){
                              if ($i =~ /$lasttime/) {
                                  DEbuglog "lasttime $count";
                                  last;
                                  };
                              $count++;
                               };
                             }; # if文用 $lastline
                     DEbuglog "ALL list written!!" if ($count == 0 );
                     foreach my $j ($count .. $#loglist) {
                         $sth_2->execute($loglist[$j]);
                             };
                     DEbuglog "DB writetting Finish";

                     # $e->w->cancel; #無限ループの為コメントアウト
                     });
    DEbuglog "Inotify setting.";

# 日付更新サブルーチン
sub spancalc {
    # 日付更新の計算
    my $ythis = time2str("%Y",time+86400);
    my $mthis = time2str("%m",time+86400);
    my $dthis = time2str("%d",time+86400);

    # 日付変更のepoc time 月は-1で指定する
    my $dayline = timelocal( 0, 0, 0, $dthis, $mthis-1, $ythis);
 
    my $span = $dayline-time; #今日の終わるまでの秒数

    DEbuglog "Date check";
    return $span;
    }

# 日付更新期間の取得
my $span = spancalc();
DEbuglog "span: $span";

my $stat = 1; #無限ループ用フラグ

DEbuglog "Event loop start";


# イベントループ
    my $cvout = AnyEvent->condvar;

    my $w = AnyEvent->signal(
        signal => "TERM",
        cb => sub {
              $stat = 0;  #whileループを止める
              $cvout->send;
              });

        while ($stat){

                my $cv = AnyEvent->condvar;

                    #ファイル監視のループ
                    my $inotify_w = AnyEvent->io (
                          fh => $inotify->fileno, 
                          poll => 'r', 
                          cb => sub { 
                                $inotify->poll;
                                DEbuglog "Check EVENT IN_MODIFY!!!"; 
                                } #無限ループで終了させない
                          );

                    #日付確認のループ
                    my $t = AnyEvent->timer(
                           after => $span,
                           interval => 0,
                           cb => sub {
                                #日付更新で$spanの変更、ログテーブルの更新
                                $span = spancalc();
                                my ($sth_1, $sth_2, $sth_3) = dbsetting();

                                # 日付テーブルの作成
                                $sth_1->execute;
                                DEbuglog "Make Table next day!";
                                undef $inotify_w; #ファイル監視ループの停止                               
                                $cv->send;
                              });


                   my $w2 = AnyEvent->signal(
                        signal => "TERM",
                        cb => sub {
                             $cv->send;
                             });
                $cv->recv;
        };
  $cvout->recv;

# Last setting

$sth_1->finish;
$sth_2->finish;
$sth_3->finish;

DEbuglog "Logging End ------------------------------";

