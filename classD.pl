#!/usr/bin/env perl

use strict;
use warnings;
use DBI;

# DB接続設定
my $db = DBI->connect("dbi:mysql:dbname=sitedata;host=192.168.0.8;port=3306","sitedata","sitedatapass",
        {RaiseError=>0, AutoCommit=>1,mysql_enable_utf8=>1});

my $sql = "INSERT INTO privip_tbl(hostaddress,class) VALUES (?,?)";
my $sth = $db->prepare($sql);

my $class = "D";

for my $col1 (224..239){

    for my $col2 (0..255) {

        for my $col3 (0..255) {

            for my $col4 (0..255){

                my $hostaddre = "$col1.$col2.$col3.$col4";

                # DBへの書き込み
                $sth->execute($hostaddre,$class);

                print "$col1.$col2.$col3.$col4";
                print "\r";

                };
            };
        };
    };
