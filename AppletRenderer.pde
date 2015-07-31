import controlP5.*;

class AppletRenderer implements ControlListener {

  private final GridView boardView;
  private final GridView previewView;
  private final GridView heldPieceView;

  AppletRenderer() {
    textSize(25);
    
    boardView = new GridView(146, 33, 300, 600);
    heldPieceView = new GridView(12, 33, 120, 60);
    heldPieceView.rows = 2;
    heldPieceView.cols = 4;
    previewView = new GridView(460, 33, 90, 150);
    previewView.rows = 10;
    previewView.cols = 6;
  }

  void renderGameState(TetrisGame currentGame) {
    background(0);

    if (currentGame == null || currentGame.isGameOver()) {
      pushStyle();

      textAlign(CENTER, BOTTOM);
      textSize(18);
      text("(press enter to begin)", width/2, height/2);

      textSize(25);
      if (currentGame == null) {
        text("READY TO PLAY", width/2, height/2 - 35);
      } else if (currentGame.isGameOver()) {
        text("GAME OVER", width/2, height/2 - 85);
        textSize(20);
        text("SCORE: " + currentGame.getScore(), width/2, height/2 - 60);
        text("LINES: " + currentGame.getLines(), width/2, height/2 - 35);
      }

      popStyle();
      return;
    }
    
    boardView.rows = currentGame.getGrid().rows;
    boardView.cols = currentGame.getGrid().cols;
    boardView.drawOutline();
    boardView.drawGrid(currentGame.getGrid(), currentGame);
    if (currentGame.getCurrent() != null) {
      boardView.drawShape(currentGame.getCurrent().shape, currentGame.getCurrent().x, currentGame.getCurrent().y);
      boardView.drawShapeOutline(currentGame.getCurrent().shape, currentGame.getCurrent().x, currentGame.getCurrent().final_row);
    }
    
    previewView.drawOutline();
    ArrayList<Shape> nextShapes = currentGame.getNextShapes();
    for (int i = 0; i < Math.min(nextShapes.size() - 1, 3); ++i) {
      Shape next = nextShapes.get(i);
      previewView.drawShape(next, 1, 1 + i * 3 - next.getFirstNonEmptyRow());
    }
    
    if (!currentGame.isHeldUsed()) {
      heldPieceView.drawOutline();
    }
    if (currentGame.getHeld() != null) {
      heldPieceView.drawShape(currentGame.getHeld(), 0, -currentGame.getHeld().getFirstNonEmptyRow());
    }
    
    fill(255);
    
    text("HELD", 10, 28);
    text("NEXT", 460, 28);

    int y = 221;
    for (ScoreValue scoreValue : currentGame.getScoreValues()) {
      text(scoreValue.displayName, 460, y);
      text(scoreValue.value, 460, y + 23);
      y += 51;
    }
  }

  @Override
  public void controlEvent(ControlEvent event) {
    if (event.name() == "play") {
      newGame();
    }
  }
}
