package firetetris;

import java.util.List;

import processing.core.PApplet;
import controlP5.Button;
import controlP5.ControlEvent;
import controlP5.ControlListener;
import controlP5.ControlP5;

class AppletRenderer implements ControlListener {

	private final TetrisSketch parent;
	private final ControlP5 controlP5;
	private final GridView boardView;
	private final GridView previewView;
	
	AppletRenderer(TetrisSketch parent) {
		this.parent = parent;
		parent.size(500, 690, PApplet.P2D);
		parent.textSize(25);
		controlP5 = new ControlP5(parent);
		Button btn = controlP5.addButton("play", 1, parent.width/2 - 35, parent.height/2, 70, 20);
		btn.setLabel("play again");
		btn.addListener(this);
		
		boardView = new GridView(20, 20, 321, 642, parent);
		previewView = new GridView(355, 20, 116, 213, parent);
		previewView.rows = 11;
		previewView.cols = 6;
	}

	void renderGameState(TetrisGame gameState) {
		parent.background(0);
		
		if (gameState.isGameOver()) {
			parent.text("GAME OVER\nSCORE: " + gameState.getScore(), parent.width/2 - 70, parent.height/2 - 50);
			controlP5.draw(); // show the play again button
			return;
		}
		
		boardView.rows = gameState.getGrid().rows;
		boardView.cols = gameState.getGrid().cols;
		boardView.drawOutline();
		boardView.drawGrid(gameState.getGrid(), gameState);
		if (gameState.getCurrent() != null) {
			boardView.drawShape(gameState.getCurrent().shape, gameState.getCurrent().x, gameState.getCurrent().y);
			boardView.drawShapeOutline(gameState.getCurrent().shape, gameState.getCurrent().x, gameState.getCurrent().final_row);
		}
		
		previewView.drawOutline();
		List<Shape> nextShapes = gameState.getNextShapes();
		for (int i = 0; i < Math.min(nextShapes.size() - 1, 3); ++i) {
			Shape next = nextShapes.get(i);
			previewView.drawShape(next, 1, 1 + i * 3 - next.getFirstNonEmptyRow());
		}
		
		parent.fill(255);
		
		parent.text("LEVEL\n" + gameState.getLevel(), parent.width - 150, 260);
		parent.text("LINES\n" + gameState.getLines(), parent.width - 150, 320);
		parent.text("SCORE\n" + gameState.getScore(), parent.width - 150, 400);
	}

	@Override
	public void controlEvent(ControlEvent event) {
		if (event.name() == "play") {
			parent.newGame();
		}
	}
}