/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/34481*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/*
  Tetris
  Author: Karl Hiner
  Controls:
  LEFT/RIGHT/DOWN to move
  UP - flip
  SPACE - hard drop (drop immediately)
 */

package firetetris;
import processing.core.*;

public class TetrisSketch extends PApplet {

	AppletRenderer renderer;
	TetrisGame gameState;

	public void setup() {
		renderer = new AppletRenderer(this);
		newGame();
	}

	public void draw() {
		gameState.update();
		renderer.renderGameState(gameState);
	}

	public void keyPressed() {
		if (gameState.isGameOver()) return;
		
		switch(keyCode) {
		case LEFT : gameState.left(); break;
		case RIGHT : gameState.right(); break;
		case UP : gameState.rotate(); break;
		case DOWN : gameState.down(); break;
		case ' ' : gameState.hardDown(); break;
		}
	}
	
	public void newGame() {
		gameState = new TetrisGame();
	}
}
