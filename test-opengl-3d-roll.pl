#!/opt/lampp/bin/perl

use strict;
use OpenGL ':all';                       # OpenGLを使いますよー

# 12の点を結んだ立方体をLINEで描く

	my $vertex = [
			 [ "0.0", "0.0", "0.0" ] ,
			 [ "1.0", "0.0", "0.0" ] ,
			 [ "1.0", "1.0", "0.0" ] ,
			 [ "0.0", "1.0", "0.0" ] ,
			 [ "0.0", "0.0", "1.0" ] ,
			 [ "1.0", "0.0", "1.0" ] ,
			 [ "1.0", "1.0", "1.0" ] ,
			 [ "0.0", "1.0", "1.0" ] 
		     ] ;
        my $edge = [
			[ 0, 1 ],
			[ 1, 2 ],
			[ 2, 3 ],
			[ 3, 0 ],
			[ 4, 5 ],
			[ 5, 6 ],
			[ 6, 7 ],
			[ 7, 4 ],
			[ 0, 4 ],
			[ 1, 5 ],
			[ 2, 6 ],
			[ 3, 7 ],
		    ];

my $w=640;
my $h=480;

# GLを使って絵を作る関数
sub displayFunc
{
	my $i;
	my $r=0;

	glClear(GL_COLOR_BUFFER_BIT);        # 絵を消去する

	glLoadIdentity();

	glColor3d(1.0, 1.0, 1.0);

	#視点位置と視線方向
	gluLookAt(3.0, 4.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

       # glLookat(###################### 

        glBegin(GL_LINES);

	 foreach my $col ( @$edge) {
		glVertex3dv_p(@$vertex[@$col[0]]->[0] , @$vertex[@$col[0]]->[1] , @$vertex[@$col[0]]->[2]);
		glVertex3dv_p(@$vertex[@$col[1]]->[0] , @$vertex[@$col[1]]->[1] , @$vertex[@$col[1]]->[2]);
			};

	glEnd();                             # 描画を終える
	
	glutSwapBuffers();                   # GLで書きこんだ結果を画面に反映させる
}

sub resize   #windowが大きさを変えた時に呼び出される
{
	glViewport(0, 0, $w, $h);
        glLoadIdentity();
        #glTranslated(0.0, 0.0, -5.0);
        #glOrtho(-2.0, 2.0, -2.0, 2.0, -2.0, 2.0);
	gluPerspective(30.0, $w / $h , 1.0, 100.0);
	gluLookAt(10.0,5.0,-10.0,	# カメラの位置
		0.0,0.0,0.0,            # 対象の位置
		 0.0,1.0,0.0);		# 上方向
}


glutInitWindowPosition(100, 100);
glutInitWindowSize($w,$h);
glutInit();                              # GLUTの準備
glutInitDisplayMode(GLUT_DOUBLE);        # ダブルバッファを使うよう指示する
glutCreateWindow($0);                    # ウィンドウ生成（引数はウィンドウタイトル）
glutDisplayFunc(\&displayFunc);          # 描画に使う関数(上で書いたdisplayFunc)を登録する
glutReshapeFunc(\&resize);
glutIdleFunc(sub{glutPostRedisplay();}); # displayFuncを呼び出し続けてもらうためのおまじない
glutMainLoop();                          # メッセージループに入る
