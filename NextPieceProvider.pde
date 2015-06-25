class NextPieceProvider {
  public boolean canProvideInfiniteBlocks() { return false; }
  public ArrayList<Shape> getNextShapes() { return null; }
  public Shape takeNextShape() { return null; }
}

class StandardNextPieceProvider extends NextPieceProvider {

  private ArrayList<Shape> nextShapes;

  StandardNextPieceProvider() {
    nextShapes = new ArrayList<Shape>();
    update();
  }

  public boolean canProvideInfiniteBlocks() { return true; }
  public ArrayList<Shape> getNextShapes() { return nextShapes; }
  
  public Shape takeNextShape() {
    Shape nextShape = nextShapes.remove(0);
    update();
    return nextShape;
  }

  private void update() {
    while (nextShapes.size() < TETRIS_SHAPES.length) {
      ArrayList<Shape> newShapes = new ArrayList<Shape>();
      for (int i = 0; i < TETRIS_SHAPES.length; ++i) {
        newShapes.add(new Shape(TETRIS_SHAPES[i]));
      }
      while (!newShapes.isEmpty()) {
        nextShapes.add(newShapes.remove((int)(Math.random() * newShapes.size())));
      }
    }
  }
}