#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use DDP;
use Data::Dumper;

use DBI;

my $database = 'test.sqlite3';
my $data_source = "dbi:SQLite:dbname=$database";
my $dbh = DBI->connect($data_source,undef,undef,{RaiseError => 0,PrintError => 0, AutoCommit =>1,});


#my $create_table = <<'EOS';
#create table book (
#    title,
#    author
#)
#EOS

my $create_table = "CREATE TABLE data_tbl(count integer primary key, data text);";

$dbh->do($create_table);


#my $drop_table = "drop table book";
#   $dbh->do($drop_table);

#my $insert = "insert into book (title, author) values (?,?);";
#$dbh->do($insert);

my $insert = "INSERT INTO data_tbl (data) values (?);";

my $sth_insert = $dbh->prepare($insert);

   $sth_insert->execute('testdata');

#   $sth_insert->execute('java','saburo');
#   $sth_insert->execute('phython','sirou');

#my $select = "select * from book;";
#my $sth = $dbh->prepare($select);
#   $sth->execute;

#while (my @row = $sth->fetchrow_array) {;

#p @row;

#    };
#$dbh->disconnect;
exit;
