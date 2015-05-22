class GameInput {
  public boolean rotateActive;
  public boolean counterRotateActive;
  public boolean downActive;
  public boolean leftActive;
  public boolean rightActive;
  public boolean hardDownActive;
  public boolean swapHeldActive;

  public void update() { }
}

class CompositeGameInput extends GameInput {
  public ArrayList<GameInput> gameInputs;

  public CompositeGameInput() {
    gameInputs = new ArrayList<GameInput>();
  }
  
  public void update() {
    for (GameInput input : gameInputs) {
      input.update();
    }

    rotateActive = false;
    for (GameInput input : gameInputs) {
      if (input.rotateActive) {
        rotateActive = true;
        break;
      }
    }
    counterRotateActive = false;
    for (GameInput input : gameInputs) {
      if (input.counterRotateActive) {
        counterRotateActive = true;
        break;
      }
    }
    downActive = false;
    for (GameInput input : gameInputs) {
      if (input.downActive) {
        downActive = true;
        break;
      }
    }
    leftActive = false;
    for (GameInput input : gameInputs) {
      if (input.leftActive) {
        leftActive = true;
        break;
      }
    }
    rightActive = false;
    for (GameInput input : gameInputs) {
      if (input.rightActive) {
        rightActive = true;
        break;
      }
    }
    hardDownActive = false;
    for (GameInput input : gameInputs) {
      if (input.hardDownActive) {
        hardDownActive = true;
        break;
      }
    }
    swapHeldActive = false;
    for (GameInput input : gameInputs) {
      if (input.swapHeldActive) {
        swapHeldActive = true;
        break;
      }
    }
  }
}