#!/opt/lampp/bin/perl

use strict;
use OpenGL ':all';                       # OpenGLを使いますよー

# GLを使って絵を作る関数
sub displayFunc
{
	glClear(GL_COLOR_BUFFER_BIT);        # 絵を消去する
	glRotated(25.0, 0.0, 1.0, 0.0);
  	glBegin(GL_POLYGON);
  	glColor3d(1.0, 0.0, 0.0); #/* 赤 */
  	glVertex2d(-0.9, -0.9);
  	glColor3d(0.0, 1.0, 0.0); #/* 緑 */
  	glVertex2d(0.9, -0.9);
  	glColor3d(0.0, 0.0, 1.0); #/* 青 */
  	glVertex2d(0.9, 0.9);
  	glColor3d(1.0, 1.0, 0.0); #/* 黄 */
  	glVertex2d(-0.9, 0.9);
	glEnd();                             # 描画を終える
	glFlush();
	
	glutSwapBuffers();                   # GLで書きこんだ結果を画面に反映させる
}

glutInit();                              # GLUTの準備
glutInitDisplayMode(GLUT_DOUBLE);        # ダブルバッファを使うよう指示する
glutCreateWindow($0);                    # ウィンドウ生成（引数はウィンドウタイトル）
glutDisplayFunc(\&displayFunc);          # 描画に使う関数(上で書いたdisplayFunc)を登録する
glutIdleFunc(sub{glutPostRedisplay();}); # displayFuncを呼び出し続けてもらうためのおまじない
glutMainLoop();                          # メッセージループに入る
