#!/opt/lampp/bin/perl

use strict;
use OpenGL ':all';                       # OpenGLを使いますよー

# GLを使って絵を作る関数
sub displayFunc
{
glClear(GL_COLOR_BUFFER_BIT);
	
	# 全体に色をつける
	glColor3f(1, 1, 0.5);      # R, G, B の順に、0.0～1.0
	glBegin(GL_TRIANGLES);
	glVertex2f(-0.5, 0.8);
	glVertex2f(-0.5, 0);
	glVertex2f(0.5, 0.4);
	glEnd();

	# 頂点ごとに色をつける
	glBegin(GL_TRIANGLES);
	glColor3f(1, 0, 0);        # この色が↓
	glVertex2f(-0.5, -0.4);    #        この頂点に適用される
	glColor3f(0, 1, 0);        # この色が↓
	glVertex2f(0.5, -0.8);     #        この頂点に適用される
	glColor3f(0, 0, 1);        # この色が↓
	glVertex2f(0.5, 0);        #        この頂点に適用される
	glEnd();
	
	glutSwapBuffers();
}

glutInit();                              # GLUTの準備
glutInitDisplayMode(GLUT_DOUBLE);        # ダブルバッファを使うよう指示する
glutCreateWindow($0);                    # ウィンドウ生成（引数はウィンドウタイトル）
glutDisplayFunc(\&displayFunc);          # 描画に使う関数(上で書いたdisplayFunc)を登録する
glutIdleFunc(sub{glutPostRedisplay();}); # displayFuncを呼び出し続けてもらうためのおまじない
glutMainLoop();                          # メッセージループに入る
