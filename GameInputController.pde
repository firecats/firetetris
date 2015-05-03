/*
  Combines multiple inputs into commands sent to a tetris game.
*/
class GameInputController {

  KeyboardGameInput keyboardInput;

  CommandDelayManager rotateCommandManager;
  CommandDelayManager downCommandManager;
  CommandDelayManager leftCommandManager;
  CommandDelayManager rightCommandManager;
  CommandDelayManager hardDownCommandManager;
  CommandDelayManager swapHeldCommandManager;

  GameInputController() {
    keyboardInput = new KeyboardGameInput();

    rotateCommandManager = new CommandDelayManager();
    downCommandManager = new CommandDelayManager();
    leftCommandManager = new CommandDelayManager();
    rightCommandManager = new CommandDelayManager();
    hardDownCommandManager = new CommandDelayManager();
    swapHeldCommandManager = new CommandDelayManager();
  }

  public void update(TetrisGame game) {
    if (game == null) return;

    keyboardInput.update();

    if (rotateCommandManager.isTriggered(keyboardInput.rotateActive)) game.rotate();
    if (downCommandManager.isTriggered(keyboardInput.downActive)) game.down();
    if (leftCommandManager.isTriggered(keyboardInput.leftActive)) game.left();
    if (rightCommandManager.isTriggered(keyboardInput.rightActive)) game.right();
    if (hardDownCommandManager.isTriggered(keyboardInput.hardDownActive)) game.hardDown();
    if (swapHeldCommandManager.isTriggered(keyboardInput.swapHeldActive)) game.swapHeldPiece();
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
