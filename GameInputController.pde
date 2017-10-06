class InputHandler {
  public void start() {}
  public void rotate() {}
  public void counterRotate() {}
  public void up() {}
  public void down() {}
  public void left() {}
  public void right() {}
  public void hardDown() {}
  public void swapHeld() {}
  public void menuUp() {}
  public void menuDown() {}
}

/*
  Combines multiple inputs into commands sent to a tetris game.
*/
class GameInputController {

  CompositeGameInput aggregateInput;
  KeyboardGameInput keyboardInput;

  CommandManager startCommandManager;
  CommandManager rotateCommandManager;
  CommandManager counterRotateCommandManager;
  CommandManager upCommandManager;
  CommandManager downCommandManager;
  CommandManager leftCommandManager;
  CommandManager rightCommandManager;
  CommandManager hardDownCommandManager;
  CommandManager swapHeldCommandManager;
  CommandManager menuUpCommandManager;
  CommandManager menuDownCommandManager;

  GameInputController(PApplet applet, Config config) {
    aggregateInput = new CompositeGameInput();
    
    keyboardInput = new KeyboardGameInput();
    aggregateInput.gameInputs.add(keyboardInput);
    
    if (config.gamepadConfiguration != "") {
      GamepadGameInput gamepadInput = new GamepadGameInput(config.gamepadConfiguration, applet);
      aggregateInput.gameInputs.add(gamepadInput);
    }

    startCommandManager = new ArmedCommandManager();
    rotateCommandManager = new ArmedCommandManager();
    counterRotateCommandManager = new ArmedCommandManager();

    if (config.arduinoInputConfiguration != "") {
      ArduinoGameInput arduinoGameInput = new ArduinoGameInput(config.arduinoInputConfiguration, applet);
      aggregateInput.gameInputs.add(arduinoGameInput);
    }

    upCommandManager = new CommandDelayManager();
    downCommandManager = new CommandDelayManager();
    leftCommandManager = new CommandDelayManager();
    rightCommandManager = new CommandDelayManager();
    hardDownCommandManager = new ArmedCommandManager();
    swapHeldCommandManager = new ArmedCommandManager();
    menuUpCommandManager = new CommandDelayManager();
    menuDownCommandManager = new CommandDelayManager();
  }

  public void update(InputHandler receiver) {
    aggregateInput.update();
    if (startCommandManager.isTriggered(aggregateInput.startActive)) receiver.start();
    if (rotateCommandManager.isTriggered(aggregateInput.rotateActive)) receiver.rotate();
    if (counterRotateCommandManager.isTriggered(aggregateInput.counterRotateActive)) receiver.counterRotate();
    if (upCommandManager.isTriggered(aggregateInput.upActive)) receiver.up();
    if (downCommandManager.isTriggered(aggregateInput.downActive)) receiver.down();
    if (leftCommandManager.isTriggered(aggregateInput.leftActive)) receiver.left();
    if (rightCommandManager.isTriggered(aggregateInput.rightActive)) receiver.right();
    if (hardDownCommandManager.isTriggered(aggregateInput.hardDownActive)) receiver.hardDown();
    if (swapHeldCommandManager.isTriggered(aggregateInput.swapHeldActive)) receiver.swapHeld();
    if (menuUpCommandManager.isTriggered(aggregateInput.menuUpActive)) receiver.menuUp();
    if (menuDownCommandManager.isTriggered(aggregateInput.menuDownActive)) receiver.menuDown();
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
