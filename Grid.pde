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

  boolean isOccupied(int x, int y) {
    if (y < 0 && x < cols && x >= 0) // allow movement/flipping to spaces above the board
      return false;
    return (x >= cols || x < 0 || y >= rows || colors[x][y] != 0);
  }

  public void updatedClearedRows() {
    clearedRows.clear();
    for (int j = 0; j < rows; ++j) {
      boolean cleared = true;
      for (int i = 0; i < cols; ++i)
        if (colors[i][j] == 0)
          cleared = false;
      
      if (cleared) clearedRows.add(j);
    }
  }
}
