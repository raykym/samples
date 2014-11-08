#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use IO::File;
use Date::Format;
use Time::Local;
use Proc::ProcessTable;
use DBI;

$| = 1; #プリントバッファの抑制

my $debug = "ON";
my $debuglog = "./adptapachelog2db.log";

sub DEbuglog {
    # debugならログファイルをopen
    open ( LOG, ">>$debuglog" ) if $debug eq 'ON';
    my $lt = localtime(time);
    say LOG "[$lt] @_" if $debug eq "ON";
    close(LOG);
    return;
    };

DEbuglog "Logging Start ------------------------------";

# /var/log/apache2/access.logを開いて、DBに書き出す。
# テーブルは日付で作成、日付で更新される。

# DB初期設定、日付更新で更新するためにサブルーチン化
sub dbsetting {
    # 日付取得 起動時
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

    return ($sth_1, $sth_2);
    }

# DB初期設定取得
my ($sth_1,$sth_2) = dbsetting();
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


# 監視ファイルハンドル設定
  my $fhaccesslog = new IO::File;
     $fhaccesslog->open("/var/log/apache2/access.log");

DEbuglog "Event loop start";

while (1) {

    #ファイルからDBへ書き出し
    if (defined $fhaccesslog) {
           my @loglist = <$fhaccesslog>;
           foreach my $line (@loglist){
                 $sth_2->execute($line);
                 DEbuglog "Check EVENT IN_MODIFY!!!";
                 }
        };
    };
#last setting

$sth_1->finish;
$sth_2->finish;

DEbuglog "Logging End ------------------------------";

