package firetetris;
import java.awt.Color;
import java.util.ArrayList;

class Grid {
	int rows, cols;
	Color[][] colors;
	ArrayList<Integer> clearedRows = new ArrayList<Integer>();

	Grid(int rows, int cols) {
		this.rows = rows;
		this.cols = cols;
		colors = new Color[cols][rows];
		for (int i = 0; i < cols; ++i)
			for (int j = 0; j < rows; ++j)
				colors[i][j] = Color.BLACK;
	}

	void clear() {
		for (int i = 0; i < cols; ++i)
			for (int j = 0; j < rows; ++j)
				colors[i][j] = Color.BLACK;
	}

	void eraseCleared() {
		for (int row : clearedRows) {
			for (int j = row - 1; j > 0; --j) {
				Color[] rowCopy = new Color[cols];
				for (int i = 0; i < cols; ++i)
					rowCopy[i] = colors[i][j];
				for (int i = 0; i < cols; ++i)
					colors[i][j + 1] = rowCopy[i];
			} 
		}
	}

	boolean isOccupied(int x, int y) {
		if (y < 0 && x < cols && x >= 0) // allow movement/flipping to spaces above the board
		return false;
		return (x >= cols || x < 0 || y >= rows || colors[x][y] != Color.BLACK);
	}

	public void updatedClearedRows() {
		clearedRows.clear();
		for (int j = 0; j < rows; ++j) {
			boolean cleared = true;
			for (int i = 0; i < cols; ++i)
				if (colors[i][j] == Color.BLACK)
					cleared = false;
			
			if (cleared) clearedRows.add(j);
		}
	}
}
