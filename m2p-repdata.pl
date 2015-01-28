#!/usr/bin/env perl

# mysqlからpostgreSQLへデータをコピーする
# トランザクションを利用してバルク書き込み。
# mysqlはパーティションからなので、order by　でcountを並べる必要がある
# postgreSQL側の最後とmysql側のエンドをチェックして終わりを決める
# mysqlは１００万レコードくらいで読んだ方が早いが、
# postgresqlは遅い、ので応答が無いようにも見えるが、プロセスを止めても動作している。
# postgresqlの書き込みは遅いので、indexを削除してから書き込みを行う。
# 完了後にindexを貼り直す。

use strict;
use warnings;
use DBI;

use AnyEvent;

#プリントバッファの抑制
$| = 1;

my $m_tbl = "p_ipsearch_tbl";
my $p_tbl = "ipsearch_tbl";

my $dbname = "sitedata";
my $dbuser = "sitedata";
my $dbpass = "sitedatapass";
my $m_host = "192.168.0.8";
my $p_host = "192.168.0.5";

# mysql
my $m_dbh = DBI->connect("dbi:mysql:dbname=$dbname;host=$m_host;port=3306","$dbuser","$dbpass",{RaiseError => 1, AutoCommit => 1, mysql_enable_utf8 => 1});

my $sql_get = "SELECT count,col0,col1,col2,col3,timestamp,icmp,http,https FROM $m_tbl order by count limit ?,?";
my $get_sth = $m_dbh->prepare($sql_get);

my $end_sql = "SELECT count FROM $m_tbl order by count DESC limit 1";
my $end_sth = $m_dbh->prepare($end_sql);
   $end_sth->execute();
my $end_ref = $end_sth->fetchrow_hashref();
my $end_count = $end_ref->{count};

# postgreSQL
# AutoCommit なし
my $p_dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$p_host;port=5432","$dbuser","$dbpass",{RaiseError => 0, AutoCommit => 0});

my $sql_insert = "INSERT INTO $p_tbl (count, col0, col1, col2, col3, timestamp, icmp, http, https) VALUES (?,?,?,?,?,?,?,?,?)";
my $insert_sth = $p_dbh->prepare($sql_insert);

my $sql_last = "SELECT count FROM $p_tbl order by count DESC limit 1";
my $last_sth = $p_dbh->prepare($sql_last);
   $last_sth->execute();
my $ref_last = $last_sth->fetchrow_hashref();
my $last_count = $ref_last->{count};
   if (defined $last_count) { $last_count++} else { $last_count = 0};

my $c_address_idx = "create index address_idx on $p_tbl(col0,col1,col2,col3)";
my $c_icmp_idx = "create index icmp_idx on $p_tbl(icmp)";
my $c_http_idx = "create index http_idx on $p_tbl(http,https)";

my $c_address_sth = $p_dbh->prepare($c_address_idx);
my $c_icmp_sth = $p_dbh->prepare($c_icmp_idx);
my $c_http_sth = $p_dbh->prepare($c_http_idx);

my $d_address_idx = "DROP INDEX if exists address_idx";
my $d_icmp_idx = "DROP INDEX if exists icmp_idx";
my $d_http_idx = "DROP INDEX if exists http_idx";

my $d_address_sth = $p_dbh->prepare($d_address_idx);
my $d_icmp_sth = $p_dbh->prepare($d_icmp_idx);
my $d_http_sth = $p_dbh->prepare($d_http_idx);

   print "DROP INDEX.....\n";
   $d_address_sth->execute() or die "Error: $d_address_sth->errstr";
   $d_icmp_sth->execute() or die "Error: $d_icmp_sth->errstr";
   $d_http_sth->execute() or die "Error: $d_http_sth->errstr";

   $p_dbh->commit;

# 100万を一区切りとして一括書き込みを行う 1000万に変更してみる。メモリが持つだろうか perlが80%になったので限界だろう。 結果から500万に変更。
my $one_limit = 5000000; 
my $bulkcount = 1000000;

print "Last: $last_count \n";
print "End: $end_count \n";

my $cv = AnyEvent->condvar;

my $t = AnyEvent->timer(
        after => 1,
        interval => 3,  #本当は１秒では終わらないが、すぐに次をという事でこのまま
        cb => sub {

        print "get list from mysql :";
        $get_sth->execute($last_count,$one_limit);

        # 進捗表示 "===  "で表示される。
              my $progre = $last_count * 100 / $end_count ;
                  printf ("%s%3d%s", $last_count, $progre, "%") ;
                  print "=" x ($progre /10 *2 );
                  print "\r" ;
        my @res;
        my $res_get = $get_sth->fetchall_arrayref(@res);

        my @line;

     while (@$res_get) {
        
        #1回コミットする分だけ分ける
        foreach (1..$bulkcount){
              push @line,shift (@$res_get) if (@$res_get);
           }

        foreach my $cols (@line){
               $insert_sth->execute(@$cols);
            }
        $p_dbh->commit;
        @line = ();

        } # whileのend

        $last_count = $last_count + $one_limit;

            if ($last_count > $end_count ) { $cv->send };
        });        

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

# メモリ解放を優先する
$get_sth->finish;
$end_sth->finish;
$m_dbh->disconnect;

print "                                           \n";
print "CREATE Index......\n";
$c_address_sth->execute();
$c_icmp_sth->execute();
$c_http_sth->execute();
$p_dbh->commit;


$insert_sth->finish;
$last_sth->finish;

