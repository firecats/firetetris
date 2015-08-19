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

class PresetNextPieceProvider extends NextPieceProvider {
  private ArrayList<Shape> nextShapes;

  PresetNextPieceProvider(ArrayList<Shape> nextShapes) {
    this.nextShapes = nextShapes;
  }

  public boolean canProvideInfiniteBlocks() { return false; }
  public ArrayList<Shape> getNextShapes() { return nextShapes; }
  
  public Shape takeNextShape() {
    if (nextShapes.size() > 0) return nextShapes.remove(0);
    else return null;
  }
}

class RandomNextPieceProvider extends NextPieceProvider {

  RandomNextPieceProvider() {
  }

  public boolean canProvideInfiniteBlocks() { return true; }
  public ArrayList<Shape> getNextShapes() { return new ArrayList<Shape>(); }
  
  public Shape takeNextShape() {
    return TETRIS_SHAPES[(int)(Math.random() * TETRIS_SHAPES.length)];
  }
}

class CompositeNextPieceProvider extends NextPieceProvider {
  public ArrayList<NextPieceProvider> providers;

  CompositeNextPieceProvider() {
    providers = new ArrayList<NextPieceProvider>();
  }

  // If any of the providers have infinite blocks, this provider can too
  public boolean canProvideInfiniteBlocks() {
    for (int i = 0; i < providers.size(); ++i) {
      if (providers.get(i).canProvideInfiniteBlocks()) return true;
    }
    return false;
  }

  // As soon as we hit an infinite block provider, we need to return since the blocks
  // of providers following it can never be reached.
  public ArrayList<Shape> getNextShapes() {
    ArrayList<Shape> nextShapes = new ArrayList<Shape>();
    for (int i = 0; i < providers.size(); ++i) {
      NextPieceProvider provider = providers.get(i);
      nextShapes.addAll(provider.getNextShapes());
      if (provider.canProvideInfiniteBlocks()) return nextShapes;
    }
    return nextShapes;
  }

  public Shape takeNextShape() {
    Shape nextShape;
    for (int i = 0; i < providers.size(); ++i) {
      nextShape = providers.get(i).takeNextShape();
      if (nextShape != null) return nextShape;
    }
    return null;
  }
}

class ToughestNextPieceProvider extends NextPieceProvider {
  private TetrisGame game;

  ToughestNextPieceProvider(TetrisGame game) {
    this.game = game;
  }

  public boolean canProvideInfiniteBlocks() { return true; }
  public ArrayList<Shape> getNextShapes() { return new ArrayList<Shape>(); }
  
  public Shape takeNextShape() {
    Shape worstShape = null;
    int worstScore = 0; // High score value is bad, find the highest

    for (int i = 0; i < TETRIS_SHAPES.length; ++i) {
      Shape s = TETRIS_SHAPES[i];
      int bestScore = -1;

      for (int orientation = 0; orientation < 4; ++orientation) {
        for (int col = 0; col < game.grid.cols; ++col) {

          s = s.rotated();

          // Create a new grid, insert the shape and score it
          Grid tested = new Grid(game.grid);
          int row = 0;
          for (; row < tested.rows; ++row) {
            if (!tested.isLegal(s, col, row)) {
              --row;
              break;
            }
          }

          if (tested.placeShape(s, col, row)) {
            // Score only counts if the dropped location was valid
            int score = tested.scoreGrid();
            if (bestScore == -1 || score < bestScore) {
              bestScore = score;
            }
          }
        }
      }

      if (bestScore > worstScore) {
        worstScore = bestScore;
        worstShape = s;
      }
    }

    return worstShape;
  }
}
