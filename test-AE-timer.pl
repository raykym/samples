#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use AnyEvent;

my $span = 5;
my $stat = 1;

my $cvout = AnyEvent->condvar;

# HUPシグナル受信時の終了処理
my $w = AnyEvent->signal(
    signal => 'HUP',
    cb => sub {
        $stat = 0;
        $cvout->send;
        }
    );


while ($stat) {
# タイマー期間を再設定するには、$cvを一度終了させる必要がある。
# 刻みを１秒づつ増やす
my $cv = AnyEvent->condvar;


my $t = AnyEvent->timer(
    after => $span,
    interval => $span,
    cb => sub {
          my $date = localtime(time);
          say "$date";
          $span++;
          $cv->send;
        }
    );


    # timerが２つあると$spanが更新されない？　テスト正しく動作しない。
    # timerが$cvを共有すると動作が正しくならない。
    my $t2 = AnyEvent->timer(
       after => 2,
       interval => 2,
       cb => sub {
             say "t2 timer say!!!!!";
            }); 

    $cv->recv;

   say "$span";
};

 $cvout->recv;  # 外側のイベントループ
