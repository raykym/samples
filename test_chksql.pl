#!/usr/bin/env perl

use strict;
use warnings;
use DBI;

my $host = "10.1.1.1";

# DB接続設定
my $db = DBI->connect("dbi:mysql:dbname=sitedata;host=192.168.0.8;port=3306","siteuser","siteuserpass",
        {RaiseError=>0, AutoCommit=>1,mysql_enable_utf8=>1});

my $chk_sql = "select hostaddress from privip_tbl where hostaddress = '$host'";
my $chk_sth = $db->prepare($chk_sql);


# プライベートアドレスチェック
   $chk_sth->execute;
my $chk_res = $chk_sth->rows;

if ($chk_res == '0') {

	print "check ok\n";
	} else {

	print "check NG\n";
	};

