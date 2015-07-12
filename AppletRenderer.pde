import controlP5.*;

class AppletRenderer implements ControlListener {

  private final GridView boardView;
  private final GridView previewView;
  private final GridView heldPieceView;
  
  private Button btnPlayAgain;
  
  AppletRenderer() {
    textSize(25);
    
    btnPlayAgain = controlP5.addButton("play", 1, width/2 - 35, height/2, 70, 20);
    btnPlayAgain.setLabel("play again");
    btnPlayAgain.addListener(this);
    
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
    
    if (currentGame.isGameOver()) {
      text("GAME OVER\nSCORE: " + currentGame.getScore(), width/2 - 70, height/2 - 50);
      controlP5.draw(); // show the play again button
      btnPlayAgain.setVisible(true);
      return;
    }
    btnPlayAgain.setVisible(false);
    
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
    heldPieceView.drawShape(currentGame.getHeld(), 0, -currentGame.getHeld().getFirstNonEmptyRow());
    
    fill(255);
    
    text("HELD", 10, 28);
    text("NEXT", 460, 28);

    text("LEVEL", 460, 221);
    text(currentGame.getLevel(), 460, 244);

    text("LINES", 460, 272);
    text(currentGame.getLines(), 460, 295);

    text("SCORE", 460, 323);
    text(currentGame.getScore(), 460, 346);
  }

  @Override
  public void controlEvent(ControlEvent event) {
    if (event.name() == "play") {
      newGame();
    }
  }
}
