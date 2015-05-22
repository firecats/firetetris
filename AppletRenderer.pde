import controlP5.*;

class AppletRenderer implements ControlListener {

  private final GridView boardView;
  private final GridView previewView;
  private final GridView heldPieceView;
  
  private Button btnPlayAgain;
  
  AppletRenderer() {
    size(500, 690, PApplet.P2D);
    textSize(25);
    
    btnPlayAgain = controlP5.addButton("play", 1, width/2 - 35, height/2, 70, 20);
    btnPlayAgain.setLabel("play again");
    btnPlayAgain.addListener(this);
    
    boardView = new GridView(20, 20, 321, 642);
    heldPieceView = new GridView(355, 20, 116, 58);
    heldPieceView.rows = 2;
    heldPieceView.cols = 4;
    previewView = new GridView(355, 88, 116, 193);
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
    
    text("LEVEL\n" + currentGame.getLevel(), width - 150, 340);
    text("LINES\n" + currentGame.getLines(), width - 150, 400);
    text("SCORE\n" + currentGame.getScore(), width - 150, 480);
  }

  @Override
  public void controlEvent(ControlEvent event) {
    if (event.name() == "play") {
      newGame();
    }
  }
}
