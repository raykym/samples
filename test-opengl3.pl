#!/opt/lampp/bin/perl

use strict;
use OpenGL ':all';                       # OpenGLを使いますよー


use Time::HiRes;
my $start_time = Time::HiRes::gettimeofday;

# GLを使って絵を作る関数
sub displayFunc
{
my $elapsed = Time::HiRes::gettimeofday - $start_time;
	my $x = $elapsed / 10;
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	glLoadIdentity();                # 座標変換を初期化するおまじない
	glTranslatef($x, $x, 0);         # 以降の全ての図形を(x, y, z)移動する
	
	glBegin(GL_TRIANGLES);
	glColor3f(1, 0, 0,);
	glVertex2f(-0.5, 0.5);
	glColor3f(0, 1, 0,);
	glVertex2f(-0.5, -0.5);
	glColor3f(0, 0, 1,);
	glVertex2f(0.9, 0);
	glEnd();
	
	glutSwapBuffers();
}


glutInit();                              # GLUTの準備
glutInitDisplayMode(GLUT_DOUBLE);        # ダブルバッファを使うよう指示する
glutCreateWindow($0);                    # ウィンドウ生成（引数はウィンドウタイトル）
glutDisplayFunc(\&displayFunc);          # 描画に使う関数(上で書いたdisplayFunc)を登録する
glutIdleFunc(sub{glutPostRedisplay();}); # displayFuncを呼び出し続けてもらうためのおまじない
glutMainLoop();                          # メッセージループに入る
