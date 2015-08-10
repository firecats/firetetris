class TetrisGame {
  
  public final static int ANIMATION_LENGTH = 25;
  private final int[] FRAMES_PER_ROW = { 53,49,45,41,37,33,28,22,17,11,10,9,8,7,6,6,5,5,4,4,3 };

  // Game properties
  private Tetromino current;
  private Audio audio;
  private ArrayList<Shape> nextShapes;
  private Shape held;
  private boolean heldUsed;
  private Grid grid;
  private Shape[] shapes = new Shape[7];

  // timer is the interval between game "steps". Every 'timer' loops, the current block is moved down.
  private int timer;
  // Represents the progress in 'timer'. Increased during every loop and reset when a block is stepped down.
  private int currTime = 0;

  // Scoring properties
  private boolean lastScoreWasSpecial;
  private boolean justScoredSpecial;
  private boolean lastMoveWasRotate;
  private boolean usedFloorKick;
  private int score;
  private int lines;
  private int level;
  
  // True if game is over, false otherwise.
  private boolean gameOver;
  
  // Countdown for animation. Animation lasts for 20 frames.
  private int animateCount;

  TetrisGame(Minim minim) {
    shapes[0] = new Shape(4, new int[] {4,5,6,7}, color(0, 255, 255), 0);   // I
    shapes[1] = new Shape(3, new int[] {1,2,3,4}, color(0,255,0), 1);       // S
    shapes[2] = new Shape(3, new int[] {0,1,4,5}, color(255,0,0), 2);     // Z
    shapes[3] = new Shape(3, new int[] {0,3,4,5}, color(0,0,255), 3);     // J
    shapes[4] = new Shape(3, new int[] {2,3,4,5}, color(255,165,0), 4);   // L
    shapes[5] = new Shape(3, new int[] {1,3,4,5}, color(160,32,240), 5);  // T
    shapes[6] = new Shape(2, new int[] {0,1,2,3}, color(255,255,0), 6);   // O
    nextShapes = new ArrayList<Shape>();
    
    grid = new Grid(TETRIS_HEIGHT, TETRIS_WIDTH);

    loadNext();

    timer = FRAMES_PER_ROW[0];
    currTime = 0;
    animateCount = -1;
    
    audio = new Audio(minim);
    audio.playMusic();

    level = 1;
    lastScoreWasSpecial = false;
    justScoredSpecial = false;
    lastMoveWasRotate = false;
    usedFloorKick = false;
  }

  public Tetromino getCurrent() {
    return current;
  }
  
  public Shape getHeld() {
    return held;
  }
  
  public boolean isHeldUsed() {
    return heldUsed;
  }

  public ArrayList<Shape> getNextShapes() {
    return nextShapes;
  }

  public Grid getGrid() {
    return grid;
  }

  public boolean getJustScoredSpecial() {
    return justScoredSpecial;
  }

  public int getScore() {
    return score;
  }

  public int getLines() {
    return lines;
  }

  public int getLevel() {
    return level;
  }

  public boolean isGameOver() {
    return gameOver;
  }

  // This is used as a timer for the "row clearing" animation. While rows are being cleared,
  // the game is temporarily suspended and the next tetromino's loading is paused
  public int getAnimateCount() {
    return animateCount;
  }

  // used when automatically moving the block down.
  private void stepDown() {
    if (current == null) return;

    if (current.y >= current.final_row) {
      finalizeShapePlacement();
    } else {
      current.y++;
      currTime = 0;
    }
  }

  // The main game loop
  public void update() {
    if(gameOver) {
      return;
    }

    // Pause for "row clearing" animation before the next piece is loaded
    if (animateCount >= 0) {
      animateCount--;
      
      // Once it's done...
      if (animateCount < 0) {
        // clear the lines, and load the next Tetromino
        grid.eraseCleared();
        loadNext();
      }
    }

    currTime++;
    
    if (currTime >= timer && animateCount < 0) {
      stepDown();
      
      // reset the timer to a negative value if player is at the bottom,
      // effectively doubling time for extra wiggle room before it locks
      if (current != null && current.y == current.final_row)
        currTime = -timer;
    }
  }

  // Cleanup that needs to happen at the end of a frame
  public void cleanup() {
    justScoredSpecial = false;
  }
  
  // Callback for the player pressing "down"
  public void down() {
    if (current == null) return;

    if (current.y >= current.final_row) {
      // if already at the bottom, down shortcuts to lock current and load next block
      finalizeShapePlacement();
    } else {
      stepDown();
    }

    lastMoveWasRotate = false;
  }
  
  // Callback for the player pressing "left"
  public void left() {
    if (current == null) return;
    
    int distance = 0;
    if (isLegal(current.shape, current.x - 1, current.y))
      distance = 1;
    else if (isLegal(current.shape, current.x - 2, current.y))
      distance = 2;

    if (distance > 0) {
      current.x -= distance;
      current.final_row = getFinalRow();
      if (current.y == current.final_row) currTime = 0;
    }

    lastMoveWasRotate = false;
  }

  // Callback for the player pressing "right"
  public void right() {
    if (current == null) return;
    
    int distance = 0;
    if (isLegal(current.shape, current.x + 1, current.y))
      distance = 1;
    else if (isLegal(current.shape, current.x + 2, current.y))
      distance = 2;

    if (distance > 0) {
      current.x += distance;
      current.final_row = getFinalRow();
      if (current.y == current.final_row) currTime = 0;
    }

    lastMoveWasRotate = false;
  }

  // move block all the way to the bottom
  public void hardDown() {
    if (current == null) return;

    current.y = current.final_row;
    finalizeShapePlacement();

    lastMoveWasRotate = false;
  }

  // Rotates block clockwise, moving it by up to two grid units in either grid X direction
  // if that permits the rotation to be legal where an in-place rotation would not
  public void rotate() {
    if (current == null) return;
    applyRotation(current.shape.rotated());
  }
  
  // Rotates block counterclockwise, moving it by up to two grid units in either grid X direction
  // if that permits the rotation to be legal where an in-place rotation would not
  public void counterRotate() {
    if (current == null) return;
    applyRotation(current.shape.counterRotated());
  }

  private void applyRotation(Shape rotated) {
    int currentX = current.x;
    int currentY = current.y;
    boolean wasRotated = true;
    boolean wasFloorKicked = false;

    if (isLegal(rotated, currentX, currentY)) {
      // Nothing to do
    } else if (isLegal(rotated, currentX + 1, currentY)) {
      current.x++;
    } else if (isLegal(rotated, currentX - 1, currentY)) {
      current.x--;
    } else if (isLegal(rotated, currentX + 2, currentY)) {
      current.x += 2;
    } else if (isLegal(rotated, currentX - 2, currentY)) {
      current.x -= 2;
      // Floor kick
    } else if (isLegal(rotated, currentX, currentY - 1)) {
      current.y -= 1;
      wasFloorKicked = true;
    } else if (isLegal(rotated, currentX, currentY - 2)) {
      current.y -= 2;
      wasFloorKicked = true;
    } else if (isLegal(rotated, currentX, currentY - 3)) {
      current.y -= 3;
      wasFloorKicked = true;
      // No rotation possible
    } else {
      wasRotated = false;
    }
    
    if (wasRotated) {
      current.shape = rotated;
      current.final_row = getFinalRow();
      audio.playRotate();
      lastMoveWasRotate = true;

      // Reset lock delay after rotation
      if (current.y == current.final_row) 
      {
        // But after floor kick is used, we stop resetting the
        // lock delay, to prevent the piece from being kicked up
        // ad infinitum
        if (!usedFloorKick)
          currTime = 0;

        usedFloorKick = usedFloorKick || wasFloorKicked;
      }
    }
  }
  
  // Allows the player (upon pressing SELECT) to swap the current 
  // tetromino with the next piece from the queue. Can be used
  // once per "turn" i.e. until the next piece is dequeued naturally.
  public void swapHeldPiece() {
    if (heldUsed || current == null) return;
    
    int currentShapeId = current.shape.shapeId;
    if (held == null) held = nextShapes.remove(0);
    insertShape(held);
    held = shapes[currentShapeId];
    
    heldUsed = true;
  }
  
  // Copies the current shape into the grid (making it part of the
  // level's collision)
  // Locks the current piece in position, tests whether the player
  // completed a line. 
  // Loads the next piece.
  //
  // This expects that the current tetromino is at its final row.
  private void finalizeShapePlacement() {
    for (int i = 0; i < current.shape.matrix.length; ++i)
      for (int j = 0; j < current.shape.matrix.length; ++j)
        if (current.shape.matrix[i][j] && j + current.y >= 0) 
          grid.colors[i + current.x][j + current.y] = current.shape.c;
    
    if (checkLines()) {
      // Start "rows cleared" animation, next piece will be loaded at end of animation 
      animateCount = ANIMATION_LENGTH;
      current = null;
    } else {
      audio.playPlace();
      loadNext();
    }
    
    heldUsed = false;
  }

  private boolean checkLines() {

    // Test for a complete line
    grid.updatedClearedRows();
    if (grid.clearedRows.isEmpty()) {
      lastScoreWasSpecial = false;
      return false;
    }

    // Increase game difficulty if enough lines cleared
    println("lines/10: "+ (lines/10));
    println("grid.clearedRows.size(): "+grid.clearedRows.size());
    if (lines/10 < (lines + grid.clearedRows.size())/10) {
      level++;
      timer = FRAMES_PER_ROW[min(level, FRAMES_PER_ROW.length) - 1];
    }

    if (grid.clearedRows.size() == 4) audio.playTetris();
    else audio.playLine();

    lines += grid.clearedRows.size();

    // Update scoring
    int scoreMultiplier = 1;
    boolean tspinAchieved = isTSpin();
    switch (grid.clearedRows.size()) {
      case 1: scoreMultiplier = (tspinAchieved ? 4 : 1); break;
      case 2: scoreMultiplier = (tspinAchieved ? 8 : 2); break;
      case 3: scoreMultiplier = (tspinAchieved ? 12 : 5); break;
      case 4: scoreMultiplier = 8; break; // TSpin can fill 3 rows maximum
    }

    justScoredSpecial = (tspinAchieved || grid.clearedRows.size() == 4);
    if (justScoredSpecial && lastScoreWasSpecial) scoreMultiplier *= 1.5;

    score += 100 * scoreMultiplier * level;

    lastScoreWasSpecial = justScoredSpecial;

    return true;
  }

  private boolean isTSpin() {
    // Following tetris DS rules from : http://tetris.wikia.com/wiki/T-Spin
    
    // 1. Last piece placed must be a T
    if (current.shape.shapeId != 5) return false;
    
    // 2. Last move was a rotatione
    if (!lastMoveWasRotate) return false;

    // 3. At least 3 corners around the T are filled.
    int cornersFilled = 0;
    if (grid.isOccupied(current.x, current.y)) ++cornersFilled;
    if (grid.isOccupied(current.x, current.y + 2)) ++cornersFilled;
    if (grid.isOccupied(current.x + 2, current.y + 2)) ++cornersFilled;
    if (grid.isOccupied(current.x + 2, current.y)) ++cornersFilled;
    return cornersFilled >= 3;
  }

  // Fills nextShapes with an equitably distributed random selection of shapes.
  // Calls insertShape, which pops the first shape from this queue and initializes 
  // the current tetromino based on this shape.
  private void loadNext() {
    while (nextShapes.size() < shapes.length) {
      ArrayList<Shape> newShapes = new ArrayList<Shape>();
      for (int i = 0; i < shapes.length; ++i) {
        newShapes.add(new Shape(shapes[i]));
      }
      while (!newShapes.isEmpty()) {
        nextShapes.add(newShapes.remove((int)(Math.random() * newShapes.size())));
      }
    }
    
    insertShape(nextShapes.remove(0));
  }

  // Initializes the current tetromino, assigns its final row
  private void insertShape(Shape shape) {
    current = new Tetromino(shape);
    current.final_row = getFinalRow();
    gameOver = !isLegal(current.shape, 3, -1);
    usedFloorKick = false;

    if(gameOver) {
      audio.stopMusic();
    }
  }

  // Based on the current position of the tetromino along the
  // x-axis, finds the bottom-most row for it, i.e. the row
  // that it would land on if it were hard-dropped
  private int getFinalRow() {
    int start = Math.max(0, current.y);
    for (int row = start; row <= grid.rows; ++row)
      if (!isLegal(current.shape, current.x, row))
        return row - 1;
    return -1;
  }

  // Performs a collision test from a shape against the blocks 
  // already in the grid. Returns true if there is no collision,
  // false if there is.
  private boolean isLegal(Shape shape, int col, int row) {
    for (int i = 0; i < shape.matrix.length; ++i)
      for (int j = 0; j < shape.matrix.length; ++j)
        if (shape.matrix[i][j] && grid.isOccupied(col + i, row + j))
          return false;
    return true;
  }
}
