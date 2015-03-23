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
	private final GridView heldPieceView;
	
	AppletRenderer(TetrisSketch parent) {
		this.parent = parent;
		parent.size(500, 690, PApplet.P2D);
		parent.textSize(25);
		controlP5 = new ControlP5(parent);
		Button btn = controlP5.addButton("play", 1, parent.width/2 - 35, parent.height/2, 70, 20);
		btn.setLabel("play again");
		btn.addListener(this);
		
		boardView = new GridView(20, 20, 321, 642, parent);
		heldPieceView = new GridView(355, 20, 116, 58, parent);
		heldPieceView.rows = 2;
		heldPieceView.cols = 4;
		previewView = new GridView(355, 88, 116, 193, parent);
		previewView.rows = 10;
		previewView.cols = 6;
	}

	void renderGameState(TetrisGame currentGame) {
		parent.background(0);
		
		if (currentGame.isGameOver()) {
			parent.text("GAME OVER\nSCORE: " + currentGame.getScore(), parent.width/2 - 70, parent.height/2 - 50);
			controlP5.draw(); // show the play again button
			return;
		}
		
		boardView.rows = currentGame.getGrid().rows;
		boardView.cols = currentGame.getGrid().cols;
		boardView.drawOutline();
		boardView.drawGrid(currentGame.getGrid(), currentGame);
		if (currentGame.getCurrent() != null) {
			boardView.drawShape(currentGame.getCurrent().shape, currentGame.getCurrent().x, currentGame.getCurrent().y);
			boardView.drawShapeOutline(currentGame.getCurrent().shape, currentGame.getCurrent().x, currentGame.getCurrent().final_row);
		}
		
		previewView.drawOutline();
		List<Shape> nextShapes = currentGame.getNextShapes();
		for (int i = 0; i < Math.min(nextShapes.size() - 1, 3); ++i) {
			Shape next = nextShapes.get(i);
			previewView.drawShape(next, 1, 1 + i * 3 - next.getFirstNonEmptyRow());
		}
		
		if (!currentGame.isHeldUsed()) {
			heldPieceView.drawOutline();
		}
		heldPieceView.drawShape(currentGame.getHeld(), 0, -currentGame.getHeld().getFirstNonEmptyRow());
		
		parent.fill(255);
		
		parent.text("LEVEL\n" + currentGame.getLevel(), parent.width - 150, 340);
		parent.text("LINES\n" + currentGame.getLines(), parent.width - 150, 400);
		parent.text("SCORE\n" + currentGame.getScore(), parent.width - 150, 480);
	}

	@Override
	public void controlEvent(ControlEvent event) {
		if (event.name() == "play") {
			parent.newGame();
		}
	}
}