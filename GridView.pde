import processing.core.*;

class GridView {
  final int x, y, width, height;
  int cols, rows;
  
  GridView(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
  
  public void drawOutline() {
    pushStyle();
    
    fill(0);
    stroke(255);
    strokeWeight(2);
    rect(x, y, width, height);
    
    popStyle();
  }
    
  public void drawGrid(Grid grid, TetrisGame currentGame) {
    pushStyle();

    for (int i = 0; i < grid.cols; ++i)
      for (int j = 0; j < grid.rows; ++j)
        fillSquare(i, j, grid.colors[i][j]);

    // line clear animation
    if (currentGame.getAnimateCount() >= 0) {
      //calculate a background that smoothly oscillates between black and white
      int c = (int) (127 + 127 * Math.cos(Math.PI * (double) currentGame.getAnimateCount() / TetrisGame.ANIMATION_LENGTH));
      // if (grid.clearedRows.size() == 4)
      //  c = color(0, c, c); // cyan animation for a Tetris
      for (int row : grid.clearedRows)
        for (int i = 0; i < grid.cols; ++i)
          fillSquare(i, row, c);//color(c, 200));
    }

    popStyle();
  }

  public void drawShape(Shape shape, int x, int y) {
    pushStyle();

    for (int i = 0; i < shape.matrix.length; ++i) {
      for (int j = 0; j < shape.matrix.length; ++j) {
        if (shape.matrix[i][j]) {
          fillSquare(x + i, y + j, shape.c);
        }
      }
    }

    popStyle();
  }
  
  private void fillSquare(int col, int row, int c) {
    if (col < 0 || col >= cols || row < 0 || row >= rows)
      return;
    
    noStroke();
    fill(c);
    rect(x + col*(width/cols), y + row*(height/rows), width/cols, height/rows);
  }

  public void drawShapeOutline(Shape shape, int x, int y) {
    pushStyle();

    for (int i = 0; i < shape.matrix.length; ++i) {
      for (int j = 0; j < shape.matrix.length; ++j) {
        if (shape.matrix[i][j]) {
          outlineSquare(x + i, y + j);
        }
      }
    }
    
    popStyle();
  }
  
  private void outlineSquare(int col, int row) {
    if (col < 0 || col >= cols || row < 0 || row >= rows)
      return;
    
    noFill();
    stroke(255);
    strokeWeight(2);
    rect(x + col*(width/cols), y + row*(height/rows), width/cols, height/rows);
  }
}