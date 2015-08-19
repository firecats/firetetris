class TetrisGame extends InputHandler {
  
  public final static int ANIMATION_LENGTH = 25;
  private final int[] FRAMES_PER_ROW = { 53,49,45,41,37,33,28,22,17,11,10,9,8,7,6,6,5,5,4,4,3 };

  // Game properties
  private Tetromino current;
  private Audio audio;
  private Shape held;
  private boolean heldUsed;
  private Grid grid;
  private NextPieceProvider nextPieceProvider;
  private ArrayList<ScoreValue> scoreValues;
  private ArrayList<GameMod> mods = new ArrayList<GameMod>();

  // timer is the interval between game "steps". Every 'timer' loops, the current block is moved down.
  private int timer;
  // Represents the progress in 'timer'. Increased during every loop and reset when a block is stepped down.
  private int currTime = 0;

  // Scoring properties
  private boolean lastScoreWasSpecial;
  private boolean justScoredSpecial;
  private boolean lastMoveWasRotate;
  private boolean usedFloorKick;
  private IntScoreValue score = new IntScoreValue("SCORE", 0);
  private IntScoreValue lines = new IntScoreValue("LINES", 0);
  private IntScoreValue level = new IntScoreValue("LEVEL", 1);
  
  // True if game is over, false otherwise.
  private boolean gameOver;
  private boolean paused;
  
  // Countdown for animation. Animation lasts for 20 frames.
  private int animateCount;

  TetrisGame(Audio aAudio) {
    nextPieceProvider = new StandardNextPieceProvider();

    grid = new Grid(TETRIS_HEIGHT, TETRIS_WIDTH);

    loadNext();

    timer = FRAMES_PER_ROW[0];
    currTime = 0;
    animateCount = -1;
    
    audio = aAudio;
    audio.playMusic();

    lastScoreWasSpecial = false;
    justScoredSpecial = false;
    lastMoveWasRotate = false;
    usedFloorKick = false;

    scoreValues = new ArrayList<ScoreValue>();
    scoreValues.add(level);
    scoreValues.add(lines);
    scoreValues.add(score);

    gameOver = false;
    paused = false;
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
    return nextPieceProvider.getNextShapes();
  }

  public Grid getGrid() {
    return grid;
  }

  public boolean getJustScoredSpecial() {
    return justScoredSpecial;
  }

  public int getScore() {
    return score.value;
  }

  public int getLines() {
    return lines.value;
  }

  public int getLevel() {
    return level.value;
  }

  public boolean isGameOver() {
    return gameOver;
  }

  public boolean isPaused() {
    return paused;
  }

  public void setPaused(boolean paused) {
    this.paused = paused;

    for (GameMod mod : mods) {
      mod.setPaused(paused);
    }
  }

  // This is used as a timer for the "row clearing" animation. While rows are being cleared,
  // the game is temporarily suspended and the next tetromino's loading is paused
  public int getAnimateCount() {
    return animateCount;
  }

  public ArrayList<ScoreValue> getScoreValues() {
    return scoreValues;
  }

  public void addMod(GameMod mod) {
    mod.initialize(this);
    mods.add(mod);
  }

  public void addScoreValue(ScoreValue scoreValue) {
    scoreValues.add(scoreValue);
  }

  public void start() {
    setPaused(true);
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

    for (GameMod mod : mods) {
      mod.update();
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
      score.value++;
      stepDown();
    }

    lastMoveWasRotate = false;
  }
  
  // Callback for the player pressing "left"
  public void left() {
    if (current == null) return;
    
    int distance = 0;
    if (grid.isLegal(current.shape, current.x - 1, current.y))
      distance = 1;
    else if (grid.isLegal(current.shape, current.x - 2, current.y))
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
    if (grid.isLegal(current.shape, current.x + 1, current.y))
      distance = 1;
    else if (grid.isLegal(current.shape, current.x + 2, current.y))
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

    score.value += (current.final_row - current.y) * 2;
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

    if (grid.isLegal(rotated, currentX, currentY)) {
      // Nothing to do
    } else if (grid.isLegal(rotated, currentX + 1, currentY)) {
      current.x++;
    } else if (grid.isLegal(rotated, currentX - 1, currentY)) {
      current.x--;
    } else if (grid.isLegal(rotated, currentX + 2, currentY)) {
      current.x += 2;
    } else if (grid.isLegal(rotated, currentX - 2, currentY)) {
      current.x -= 2;
      // Floor kick
    } else if (grid.isLegal(rotated, currentX, currentY - 1)) {
      current.y -= 1;
      wasFloorKicked = true;
    } else if (grid.isLegal(rotated, currentX, currentY - 2)) {
      current.y -= 2;
      wasFloorKicked = true;
    } else if (grid.isLegal(rotated, currentX, currentY - 3)) {
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
  public void swapHeld() {
    if (heldUsed || current == null) return;
    
    int currentShapeId = current.shape.shapeId;
    if (held == null) held = nextPieceProvider.takeNextShape();
    insertShape(held);
    held = TETRIS_SHAPES[currentShapeId];
    
    heldUsed = true;
  }

  public void endGame() {
    gameOver = true;
    if(gameOver) {
      audio.stopMusic();
    }
  }

  public void transitionToProvider(NextPieceProvider provider) {
    CompositeNextPieceProvider newProvider = new CompositeNextPieceProvider();
    ArrayList<Shape> currentNextShapes = getNextShapes();
    if (currentNextShapes.size() > 3) currentNextShapes.subList(3, currentNextShapes.size()).clear();
    newProvider.providers.add(new PresetNextPieceProvider(currentNextShapes));
    newProvider.providers.add(provider);
    nextPieceProvider = newProvider;
  }
  
  // Copies the current shape into the grid (making it part of the
  // level's collision)
  // Locks the current piece in position, tests whether the player
  // completed a line. 
  // Loads the next piece.
  //
  // This expects that the current tetromino is at its final row.
  private void finalizeShapePlacement() {
    if (current == null) return;

    if (!grid.placeShape(current.shape, current.x, current.y)) {
      // Failed to place the shape, this should not happen since we check for legality before moving 'current'.
      println("Failed to place shape at specified location");
    }
    
    if (checkLines()) {
      // Start "rows cleared" animation, next piece will be loaded at end of animation 
      animateCount = ANIMATION_LENGTH;
      current = null;
    } else {
      if (isTSpin()) {
        // bonus points for doing a T-Spin but not clearing lines
        score.value += 200 * level.value;
      }

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
    if (lines.value/10 < (lines.value + grid.clearedRows.size())/10) {
      level.value++;
      timer = FRAMES_PER_ROW[min(level.value, FRAMES_PER_ROW.length) - 1];
    }

    if (grid.clearedRows.size() == 4) audio.playTetris();
    else audio.playLine();

    lines.value += grid.clearedRows.size();

    // Update scoring
    int scoreMultiplier = 1;
    boolean tspinAchieved = isTSpin();
    switch (grid.clearedRows.size()) {
      case 1: scoreMultiplier = (tspinAchieved ? 8 : 1); break;
      case 2: scoreMultiplier = (tspinAchieved ? 12 : 2); break;
      case 3: scoreMultiplier = (tspinAchieved ? 16 : 5); break;
      case 4: scoreMultiplier = 8; break; // TSpin can fill 3 rows maximum
    }

    justScoredSpecial = (tspinAchieved || grid.clearedRows.size() == 4);
    if (justScoredSpecial && lastScoreWasSpecial) scoreMultiplier *= 1.5;

    score.value += 100 * scoreMultiplier * level.value;

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
    insertShape(nextPieceProvider.takeNextShape());
  }

  // Initializes the current tetromino, assigns its final row
  private void insertShape(Shape shape) {
    current = new Tetromino(shape);
    current.final_row = getFinalRow();
    usedFloorKick = false;
    if (!grid.isLegal(current.shape, current.x, -1)) endGame();
  }

  // Based on the current position of the tetromino along the
  // x-axis, finds the bottom-most row for it, i.e. the row
  // that it would land on if it were hard-dropped
  private int getFinalRow() {
    if (current == null) return -1;

    int start = Math.max(0, current.y);
    for (int row = start; row <= grid.rows; ++row)
      if (!grid.isLegal(current.shape, current.x, row))
        return row - 1;
    return -1;
  }
}
