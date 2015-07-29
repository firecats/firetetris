/*
  Combines multiple inputs into commands sent to a tetris game.
*/
class GameInputController {

  CompositeGameInput aggregateInput;
  KeyboardGameInput keyboardInput;

  CommandManager newGameCommandManager;
  CommandManager rotateCommandManager;
  CommandManager counterRotateCommandManager;
  CommandManager downCommandManager;
  CommandManager leftCommandManager;
  CommandManager rightCommandManager;
  CommandManager hardDownCommandManager;
  CommandManager swapHeldCommandManager;

  GameInputController(PApplet applet, Config config) {
    aggregateInput = new CompositeGameInput();
    
    keyboardInput = new KeyboardGameInput();
    aggregateInput.gameInputs.add(keyboardInput);
    
    if (config.gamepadConfiguration != "") {
      GamepadGameInput gamepadInput = new GamepadGameInput(config.gamepadConfiguration, applet);
      aggregateInput.gameInputs.add(gamepadInput);
    }

    newGameCommandManager = new ArmedCommandManager();
    rotateCommandManager = new ArmedCommandManager();
    counterRotateCommandManager = new ArmedCommandManager();

    if (config.arduinoInputConfiguration != "") {
      ArduinoGameInput arduinoGameInput = new ArduinoGameInput(config.arduinoInputConfiguration, applet);
      aggregateInput.gameInputs.add(arduinoGameInput);
    }

    downCommandManager = new CommandDelayManager();
    leftCommandManager = new CommandDelayManager();
    rightCommandManager = new CommandDelayManager();
    hardDownCommandManager = new ArmedCommandManager();
    swapHeldCommandManager = new ArmedCommandManager();
  }

  public void update(TetrisGame game) {
    aggregateInput.update();

    if (game == null || game.isGameOver()) {
      if (newGameCommandManager.isTriggered(aggregateInput.newGameActive)) newGame();
    } else {
      if (rotateCommandManager.isTriggered(aggregateInput.rotateActive)) game.rotate();
      if (counterRotateCommandManager.isTriggered(aggregateInput.counterRotateActive)) game.counterRotate();
      if (downCommandManager.isTriggered(aggregateInput.downActive)) game.down();
      if (leftCommandManager.isTriggered(aggregateInput.leftActive)) game.left();
      if (rightCommandManager.isTriggered(aggregateInput.rightActive)) game.right();
      if (hardDownCommandManager.isTriggered(aggregateInput.hardDownActive)) game.hardDown();
      if (swapHeldCommandManager.isTriggered(aggregateInput.swapHeldActive)) game.swapHeldPiece();
    }
  }

  public void keyPressed() {
    keyboardInput.keyPressed();
  }

  public void keyReleased() {
    keyboardInput.keyReleased();
  }
}

/*
  Controls how often commands should be executed based on input activity.
*/
class CommandManager {

  /*
    active - if the input is active right now
    returns - if the command should be triggered now
  */
  public boolean isTriggered(boolean active) { return false; }
}

/*
  Controls the "delay" of sending keypresses for standardization between input methods.
*/
class CommandDelayManager extends CommandManager {
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

/*
  Prevents a command from auto-repeating. The input must be released to be re-armed and then activated to be triggered.
*/
class ArmedCommandManager extends CommandManager {
    private boolean wasActive;

    ArmedCommandManager() {
      wasActive = false;
    }

    public boolean isTriggered(boolean active) {
      boolean isTriggered = active && !wasActive;
      wasActive = active;
      return isTriggered;
    }
}
