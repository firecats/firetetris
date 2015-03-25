class Tetromino {
  Shape shape;
  int x, y;
  int final_row;

  Tetromino(Shape shape) {
    this.shape = new Shape(shape);
    x = (10 - shape.matrix.length) / 2;
    y = -2;
  }
}
