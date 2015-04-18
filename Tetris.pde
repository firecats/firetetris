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

Config config;
AppletRenderer renderer;
UDPRenderer udpRenderer;
TetrisGame currentGame;
ControlP5 controlP5;

public void setup() {
  controlP5 = new ControlP5(this);
  renderer = new AppletRenderer();
  udpRenderer = new UDPRenderer(config);
  newGame();
  color a = color(1,1,1);
}

public void draw() {
  currentGame.update();
  renderer.renderGameState(currentGame);
  udpRenderer.renderGameState(currentGame);
}

public void keyPressed() {
  if (currentGame.isGameOver()) return;
  
  switch(keyCode) {
  case LEFT : currentGame.left(); break;
  case RIGHT : currentGame.right(); break;
  case UP : currentGame.rotate(); break;
  case DOWN : currentGame.down(); break;
  case SHIFT: currentGame.swapHeldPiece(); break;
  case ' ' : currentGame.hardDown(); break;
  }
}

public void newGame() {
  currentGame = new TetrisGame();
}
