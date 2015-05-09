/*
  Combines multiple inputs into commands sent to a tetris game.
*/
class GameInputController {

  CompositeGameInput aggregateInput;
  KeyboardGameInput keyboardInput;
  GamepadGameInput gamepadInput;

  CommandDelayManager rotateCommandManager;
  CommandDelayManager counterRotateCommandManager;
  CommandDelayManager downCommandManager;
  CommandDelayManager leftCommandManager;
  CommandDelayManager rightCommandManager;
  CommandDelayManager hardDownCommandManager;
  CommandDelayManager swapHeldCommandManager;

  GameInputController(PApplet applet) {
    keyboardInput = new KeyboardGameInput();
    gamepadInput = new GamepadGameInput(applet);
    aggregateInput = new CompositeGameInput();
    aggregateInput.gameInputs.add(keyboardInput);
    aggregateInput.gameInputs.add(gamepadInput);

    rotateCommandManager = new CommandDelayManager();
    counterRotateCommandManager = new CommandDelayManager();
    downCommandManager = new CommandDelayManager();
    leftCommandManager = new CommandDelayManager();
    rightCommandManager = new CommandDelayManager();
    hardDownCommandManager = new CommandDelayManager();
    swapHeldCommandManager = new CommandDelayManager();
  }

  public void update(TetrisGame game) {
    if (game == null) return;

    aggregateInput.update();

    if (rotateCommandManager.isTriggered(aggregateInput.rotateActive)) game.rotate();
    if (counterRotateCommandManager.isTriggered(aggregateInput.counterRotateActive)) game.counterRotate();
    if (downCommandManager.isTriggered(aggregateInput.downActive)) game.down();
    if (leftCommandManager.isTriggered(aggregateInput.leftActive)) game.left();
    if (rightCommandManager.isTriggered(aggregateInput.rightActive)) game.right();
    if (hardDownCommandManager.isTriggered(aggregateInput.hardDownActive)) game.hardDown();
    if (swapHeldCommandManager.isTriggered(aggregateInput.swapHeldActive)) game.swapHeldPiece();
  }

  public void keyPressed() {
    keyboardInput.keyPressed();
  }

  public void keyReleased() {
    keyboardInput.keyReleased();
  }
}

/*
  Controls the "delay" of sending keypresses for standardization between input methods.
*/
class CommandDelayManager {
    private int[] delayValues;
    private int delayIndex;
    private int currentDelay;

    CommandDelayManager() {
      delayValues = new int[] { 10, 5, 3, 1 };
      delayIndex = -1;
      currentDelay = -1;
    }

    public boolean isTriggered(boolean active) {
      if (active) {
        if (delayIndex < 0) { // just became active, initiate the delay sequence
          delayIndex = 0;
          currentDelay = delayValues[delayIndex];
          return true;
        } else {
          if (--currentDelay < 0) {
            delayIndex = min(delayIndex + 1, delayValues.length - 1);
            currentDelay = delayValues[delayIndex];
            return true;
          } else {
            return false;
          }
        }
      } else {
        delayIndex = -1;
        return false;
      }
    }
}
