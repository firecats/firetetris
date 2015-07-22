class TetrisGame {
  
  public final static int ANIMATION_LENGTH = 25;
  private final static int SPEED_DECREASE = 2;

  // Game properties
  private Tetromino current;
  private Audio audio;
  private ArrayList<Shape> nextShapes;
  private Shape held;
  private boolean heldUsed;
  private Grid grid;
  private Shape[] shapes = new Shape[7];

  // Timer is the interval between game "steps". Every 'timer' loops, the current block is moved down.
  private int timer = 20;
  // Represents the progress in 'timer'. Increased during every loop and reset when a block is .
  private int currTime = 0;

  // Scoring properties
  private boolean lastScoreWasSpecial;
  private boolean lastMoveWasRotate;
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

    currTime = 0;
    animateCount = -1;
    
    audio = new Audio(minim);
    audio.playMusic();

    level = 1;
    lastScoreWasSpecial = false;
    lastMoveWasRotate = false;
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

  public void update() {
    if(gameOver) {
      return;
    }
    
    if (animateCount >= 0) {
      animateCount--;
      
      if (animateCount < 0) {
        // clear the lines, and load the next Tetromino
        grid.eraseCleared();
        loadNext();
      }
    }

    currTime++;
    
    if (currTime >= timer && animateCount < 0) {
      stepDown();
      
      // reset the timer if player is at the bottom, for wiggle room before it locks
      if (current != null && current.y == current.final_row)
        currTime = -20;
    }
  }
  
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
  
  public void left() {
    if (current == null) return;
    
    if (isLegal(current.shape, current.x - 1, current.y))
      current.x--;
    else if (isLegal(current.shape, current.x - 2, current.y))
      current.x -= 2;
    current.final_row = getFinalRow();

    lastMoveWasRotate = false;
  }

  public void right() {
    if (current == null) return;
    
    if (isLegal(current.shape, current.x + 1, current.y))
      current.x++;
    else if (isLegal(current.shape, current.x + 2, current.y))
      current.x += 2;
    current.final_row = getFinalRow();

    lastMoveWasRotate = false;
  }

  // move block all the way to the bottom
  public void hardDown() {
    if (current == null) return;

    current.y = current.final_row;
    finalizeShapePlacement();

    lastMoveWasRotate = false;
  }

  public void rotate() {
    if (current == null) return;

    Shape rotated = current.shape.rotated();
    int currentX = current.x;
    int currentY = current.y;
    
    if (isLegal(rotated, currentX, currentY)) {
      current.shape = rotated;
      current.final_row = getFinalRow();
    } else if (isLegal(rotated, currentX + 1, currentY) || isLegal(rotated, currentX + 2, currentY)) {
      current.shape = rotated;
      right();
    } else if (isLegal(rotated, currentX - 1, currentY) || isLegal(rotated, currentX - 2, currentY)) {
      current.shape = rotated;
      left();
    }
    
    audio.playRotate();

    lastMoveWasRotate = true;
  }
  
  public void counterRotate() {
    if (current == null) return;

    Shape rotated = current.shape.counterRotated();
    int currentX = current.x;
    int currentY = current.y;
    
    if (isLegal(rotated, currentX, currentY)) {
      current.shape = rotated;
      current.final_row = getFinalRow();
    } else if (isLegal(rotated, currentX + 1, currentY) || isLegal(rotated, currentX + 2, currentY)) {
      current.shape = rotated;
      right();
    } else if (isLegal(rotated, currentX - 1, currentY) || isLegal(rotated, currentX - 2, currentY)) {
      current.shape = rotated;
      left();
    }
     
     audio.playRotate();

    lastMoveWasRotate = true;
  }
  
  public void swapHeldPiece() {
    if (heldUsed || current == null) return;
    
    int currentShapeId = current.shape.shapeId;
    if (held == null) held = nextShapes.remove(0);
    insertShape(held);
    held = shapes[currentShapeId];
    
    heldUsed = true;
  }
  
  private void finalizeShapePlacement() {
    for (int i = 0; i < current.shape.matrix.length; ++i)
      for (int j = 0; j < current.shape.matrix.length; ++j)
        if (current.shape.matrix[i][j] && j + current.y >= 0) 
          grid.colors[i + current.x][j + current.y] = current.shape.c;
    
    if (checkLines()) {
      audio.playLine();
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
    grid.updatedClearedRows();
    if (grid.clearedRows.isEmpty()) {
      lastScoreWasSpecial = false;
      return false;
    }

    if (lines/10 < (lines + grid.clearedRows.size())/10) {
      level++;
      timer -= SPEED_DECREASE;
    }
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

    boolean specialAchieved = (tspinAchieved || grid.clearedRows.size() == 4);
    if (specialAchieved && lastScoreWasSpecial) scoreMultiplier *= 1.5;

    score += 100 * scoreMultiplier * level;

    lastScoreWasSpecial = specialAchieved;

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

  private void insertShape(Shape shape) {
    current = new Tetromino(shape);
    current.final_row = getFinalRow();
    gameOver = !isLegal(current.shape, 3, -1);
    
    if(gameOver) {
      audio.stopMusic();
    }
  }

  private int getFinalRow() {
    int start = Math.max(0, current.y);
    for (int row = start; row <= grid.rows; ++row)
      if (!isLegal(current.shape, current.x, row))
        return row - 1;
    return -1;
  }

  private boolean isLegal(Shape shape, int col, int row) {
    for (int i = 0; i < shape.matrix.length; ++i)
      for (int j = 0; j < shape.matrix.length; ++j)
        if (shape.matrix[i][j] && grid.isOccupied(col + i, row + j))
          return false;
    return true;
  }
}
