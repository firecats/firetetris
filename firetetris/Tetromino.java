package firetetris;

import java.awt.Color;

class Tetromino {
	Shape shape;
	int x, y;
	int final_row;

	Tetromino(Shape shape) {
		this.shape = new Shape(shape);
		x = 3;
		y = -2;
	}

	Color getColor() { return shape.c; }
}
