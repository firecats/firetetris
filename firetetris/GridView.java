package firetetris;

import java.awt.Color;

import processing.core.PApplet;

class GridView {
	final int x, y, width, height;
	int cols, rows;
	PApplet parent;
	
	GridView(int x, int y, int width, int height, PApplet parent) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.parent = parent;
	}
	
	public void drawOutline() {
		parent.pushStyle();
		
		parent.fill(0);
		parent.stroke(255);
		parent.strokeWeight(2);
		parent.rect(x, y, width, height);
		
		parent.popStyle();
	}
	
	private int convertColor(Color c) {
		return parent.color(c.getRed(), c.getGreen(), c.getBlue());
	}
	
	public void drawGrid(Grid grid, TetrisGame currentGame) {
		parent.pushStyle();

		for (int i = 0; i < grid.cols; ++i)
			for (int j = 0; j < grid.rows; ++j)
				fillSquare(i, j, convertColor(grid.colors[i][j]));

		// line clear animation
		if (currentGame.getAnimateCount() >= 0) {
			//calculate a background that smoothly oscillates between black and white
			int c = (int) (127 + 127 * Math.cos(Math.PI * (double) currentGame.getAnimateCount() / TetrisGame.ANIMATION_LENGTH));
			if (grid.clearedRows.size() == 4)
				c = parent.color(0, c, c); // cyan animation for a Tetris
			for (int row : grid.clearedRows)
				for (int i = 0; i < grid.cols; ++i)
					fillSquare(i, row, parent.color(c, 200));
		}

		parent.popStyle();
	}

	public void drawShape(Shape shape, int x, int y) {
		parent.pushStyle();

		for (int i = 0; i < shape.matrix.length; ++i) {
			for (int j = 0; j < shape.matrix.length; ++j) {
				if (shape.matrix[i][j]) {
					fillSquare(x + i, y + j, convertColor(shape.c));
				}
			}
		}

		parent.popStyle();
	}
	
	private void fillSquare(int col, int row, int c) {
		if (col < 0 || col >= cols || row < 0 || row >= rows)
			return;
		
		parent.noStroke();
		parent.fill(parent.color(c));
		parent.rect(x + col*(width/cols), y + row*(height/rows), width/cols, height/rows);
	}

	public void drawShapeOutline(Shape shape, int x, int y) {
		parent.pushStyle();

		for (int i = 0; i < shape.matrix.length; ++i) {
			for (int j = 0; j < shape.matrix.length; ++j) {
				if (shape.matrix[i][j]) {
					outlineSquare(x + i, y + j);
				}
			}
		}
		
		parent.popStyle();
	}
	
	private void outlineSquare(int col, int row) {
		if (col < 0 || col >= cols || row < 0 || row >= rows)
			return;
		
		parent.noFill();
		parent.stroke(255);
		parent.strokeWeight(2);
		parent.rect(x + col*(width/cols), y + row*(height/rows), width/cols, height/rows);
	}
}