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
 
import ddf.minim.*;

Config config;
AppletRenderer renderer;
UDPRenderer udpRenderer;
TetrisGame currentGame;
GameInputController inputController;
ControlP5 controlP5;
Minim minim;

public void setup() {
  size(500, 690, PApplet.P2D); // Must be the first call in setup()

  controlP5 = new ControlP5(this);
  inputController = new GameInputController(this, config);
  renderer = new AppletRenderer();
  udpRenderer = new UDPRenderer(config);
  
  minim = new Minim(this);
  
  newGame();
  color a = color(1,1,1);

}

public void draw() {
  inputController.update(currentGame);
  currentGame.update();
  renderer.renderGameState(currentGame);
  udpRenderer.renderGameState(currentGame);
}

public void keyPressed() {
  inputController.keyPressed();
}

public void keyReleased() {
  inputController.keyReleased();
}

public void newGame() {
  minim.stop();
  currentGame = new TetrisGame(minim);
}
