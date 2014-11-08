#!/opt/lampp/bin/perl

use strict;
use OpenGL ':all';                       # OpenGLを使いますよー

# GLを使って絵を作る関数
sub displayFunc
{
	glClear(GL_COLOR_BUFFER_BIT);        # 絵を消去する
	
	glBegin(GL_TRIANGLES);               # 三角形を描き始める
	glVertex2f(-0.5, 0.5);               # 一つ目の頂点は(-0.5, 0.5)
	glVertex2f(-0.5, -0.5);              # 二つ目の頂点は(-0.5, -0.5)
	glVertex2f(0.9, 0);                  # 三つ目の頂点は(0.9, 0)
	glEnd();                             # 描画を終える
	
	glutSwapBuffers();                   # GLで書きこんだ結果を画面に反映させる
}

glutInit();                              # GLUTの準備
glutInitDisplayMode(GLUT_DOUBLE);        # ダブルバッファを使うよう指示する
glutCreateWindow($0);                    # ウィンドウ生成（引数はウィンドウタイトル）
glutDisplayFunc(\&displayFunc);          # 描画に使う関数(上で書いたdisplayFunc)を登録する
glutIdleFunc(sub{glutPostRedisplay();}); # displayFuncを呼び出し続けてもらうためのおまじない
glutMainLoop();                          # メッセージループに入る
