class Grid {
  int rows, cols;
  color[][] colors;
  ArrayList<Integer> clearedRows = new ArrayList<Integer>();

  Grid(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    colors = new color[cols][rows];
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j)
        colors[i][j] = 0;
  }

  Grid(Grid other) {
    this.rows = other.rows;
    this.cols = other.cols;
    colors = new color[cols][rows];
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j)
        colors[i][j] = other.colors[i][j];
  }

  void clear() {
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j)
        colors[i][j] = 0;
  }

  void eraseCleared() {
    for (int row : clearedRows) {
      for (int j = row - 1; j >= 0; --j) {
        for (int i = 0; i < cols; ++i)
          colors[i][j + 1] = colors[i][j];
      }
      for (int i = 0; i < cols; ++i)
        colors[i][0] = 0;
    }
  }

  public boolean placeShape(Shape s, int x, int y) {
    for (int i = 0; i < s.matrix.length; ++i) {
      for (int j = 0; j < s.matrix.length; ++j) {
        if (s.matrix[i][j]) {
          int col = i + x;
          int row = j + y;
          
          if (row < 0)
            continue;
          else if (row < rows && (col >= 0 && col < cols))
            colors[i + x][j + y] = s.c;
          else
            return false;
        }
      }
    }
    return true;
  }

  boolean isOccupied(int x, int y) {
    if (y < 0 && x < cols && x >= 0) // allow movement/flipping to spaces above the board
      return false;
    return (x >= cols || x < 0 || y >= rows || colors[x][y] != 0);
  }

  // Performs a collision test from a shape against the blocks 
  // already in the grid. Returns true if there is no collision,
  // false if there is.
  public boolean isLegal(Shape shape, int col, int row) {
    for (int i = 0; i < shape.matrix.length; ++i)
      for (int j = 0; j < shape.matrix.length; ++j)
        if (shape.matrix[i][j] && isOccupied(col + i, row + j))
          return false;
    return true;
  }

  public void updatedClearedRows() {
    clearedRows.clear();
    for (int j = 0; j < rows; ++j) {
      boolean cleared = true;
      for (int i = 0; i < cols; ++i)
        if (colors[i][j] == 0) {
          cleared = false;
          break;
        }
      
      if (cleared) clearedRows.add(j);
    }
  }

  // Higher values represent a more challenging grid to clear
  public int scoreGrid() {
    int numberHoles = 0; // A hole is an empty cell that has a filled cell immediately above it (a hole with a height of 2 is worth the same as a hole with a height of 1)
    int highestFilleCell = 0;
    int numberFilledCells = 0;
    int weighedFilledCells = 0; // The number of filled cells each multiplied by their height
    int biggestSlope = 0; // The highest difference in height between a column and it's neighbors
    int roughness = 0; // Roughness is the sum of the slopes of all columns

    int[] columnHeights = new int[cols];

    for (int row = 0; row < rows; ++row) {
      int height = rows - row;

      for (int col = 0; col < cols; ++col) {

        if (colors[col][row] == 0) {
          // Cell is empty, check above if it's filled -> hole
          if (row > 0 && colors[col][row-1] != 0) {
            ++numberHoles;
          }
        } else {
          // Cell is filled, update the score
          if (height > columnHeights[col]) columnHeights[col] = height;
          ++numberFilledCells;
          weighedFilledCells += height;
        }
      }
    }

    for (int col = 0; col < cols; ++col) {
      int height = columnHeights[col];
      if (height > highestFilleCell) highestFilleCell = height;
      
      if (col < (cols - 1)) {
        int slope = abs(height - columnHeights[col + 1]);
        if (slope > biggestSlope) biggestSlope = slope;
        roughness += slope;
      }
    }

    return 20 * numberHoles + highestFilleCell + numberFilledCells + weighedFilledCells + biggestSlope + roughness;
  }
}
