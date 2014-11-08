#!/opt/lampp/bin/perl

use strict;
use OpenGL ':all';                       # OpenGLを使いますよー

use Time::HiRes;
my $start_time = Time::HiRes::gettimeofday;

# 三角形を一つ描く関数
sub drawTriangle
{
	glBegin(GL_TRIANGLES);
	glColor3f(1, 0, 0);
	glVertex2f(0.3, 0);
        glColor3f(0, 1, 0);
	glVertex2f(-0.3, 0.2);
	glColor3f(0, 0, 1);
	glVertex2f(-0.3, -0.2);
	glEnd();
}

# GLを使って絵を作る関数
sub displayFunc
{
	my $elapsed = Time::HiRes::gettimeofday - $start_time;
	my $x = sin($elapsed);
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	glLoadIdentity();                      # 座標変換を初期化
	glTranslatef(-0.5 + $x * 0.2, 0.5, 0); # 以降の絵を移動する
	drawTriangle();
	
	glLoadIdentity();                      # 座標変換を初期化
	glTranslatef(0.5, 0.5, 0);             # 以降の絵を移動する
	glRotatef($x * 60, 0, 0, 1);           # 以降の絵を回転させる
	drawTriangle();
	
	glLoadIdentity();                      # 座標変換を初期化
	glTranslatef(-0.5, -0.5, 0);           # 以降の絵を移動する
	glScalef($x, $x, $x);                  # 以降の絵を拡大させる
	drawTriangle();
	
	glLoadIdentity();                      # 座標変換を初期化
	glTranslatef(0.5, -0.5, 0);            # 以降の絵を移動する
	glRotatef($x * -360, 0, 0, 1);         # 以降の絵を回転させる
	glScalef($x + 1, $x + 1, 1);           # 以降の絵を拡大させる
	glTranslatef(0, $x, 0);                # 以降の絵を移動する
	drawTriangle();
	
	glutSwapBuffers();
}

glutInit();                              # GLUTの準備
glutInitDisplayMode(GLUT_DOUBLE);        # ダブルバッファを使うよう指示する
glutCreateWindow($0);                    # ウィンドウ生成（引数はウィンドウタイトル）
glutDisplayFunc(\&displayFunc);          # 描画に使う関数(上で書いたdisplayFunc)を登録する
glutIdleFunc(sub{glutPostRedisplay();}); # displayFuncを呼び出し続けてもらうためのおまじない
glutMainLoop();                          # メッセージループに入る
