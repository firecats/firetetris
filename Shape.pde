class Shape {
	boolean[][] matrix;
	color c;
	int shapeId;

	Shape(int n, int[] blockNums, color c, int shapeId) {
		matrix = new boolean[n][n];
		for (int x = 0; x < n; ++x)
			for (int y = 0; y < n; ++y) 
				matrix[x][y] = false;
		for (int i = 0; i < blockNums.length; ++i)
			matrix[blockNums[i]%n][blockNums[i]/n] = true;
		this.c = c;
		this.shapeId = shapeId;
	}
	
	Shape(boolean[][] matrix, color c, int shapeId) {
		this.matrix = matrix;
		this.c = c;
		this.shapeId = shapeId;
	}

	Shape(Shape other) {
		matrix = new boolean[other.matrix.length][other.matrix.length];
		for (int x = 0; x < matrix.length; ++x)
			for (int y = 0; y < matrix.length; ++y)
				matrix[x][y] = other.matrix[x][y];
		this.c = other.c;
		this.shapeId = other.shapeId;
	}

	public Shape rotated() {
		boolean[][] ret = new boolean[matrix.length][matrix.length];
		for (int x = 0; x < ret.length; ++x)
			for (int y = 0; y < ret.length; ++y)
				ret[x][y] = matrix[y][ret.length - 1 - x];
		return new Shape(ret, c, this.shapeId);
	}

	public int getFirstNonEmptyRow() {
		for (int j = 0; j < matrix.length; ++j) {
			for (int i = 0; i < matrix.length; ++i) {
				if (matrix[i][j]) return j;
			}
		}
		return matrix.length;
	}
}
