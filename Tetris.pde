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

final static int TETRIS_WIDTH = 10;
final static int TETRIS_HEIGHT = 20;

Config config;
AppletRenderer renderer;
UDPRenderer udpRenderer;
TetrisGame currentGame;
GameInputController inputController;
ControlP5 controlP5;
Minim minim;

public void setup() {
  size(562, 666, PApplet.P2D); // Must be the first call in setup()

  controlP5 = new ControlP5(this);
  inputController = new GameInputController(this, config);
  renderer = new AppletRenderer();
  udpRenderer = new UDPRenderer(config);
  
  minim = new Minim(this);
}

public void draw() {
  inputController.update(currentGame);
  if (currentGame != null) currentGame.update();
  renderer.renderGameState(currentGame);
  udpRenderer.renderGameState(currentGame);
}

boolean ctrlPressed = false;

public void keyPressed() {
  if (key == ESC) {
    // Ignore escape being pressed. This prevents the default quit behavior.
    key = 0;
  } else if (char(keyCode) == 'Q' && ctrlPressed) {
    // Flush displays and exit
    renderer.renderGameState(null);
    udpRenderer.renderGameState(null);
    exit();
  } else if (keyCode == CONTROL) {
    ctrlPressed = true;
  }

  inputController.keyPressed();
}

public void keyReleased() {
  if (keyCode == CONTROL) {
    ctrlPressed = false;
  }

  inputController.keyReleased();
}

public void newGame() {
  minim.stop();
  currentGame = new TetrisGame(minim);
}
