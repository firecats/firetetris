class GameInput {
  public boolean newGameActive;
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
    newGameActive = false;
    rotateActive = false;
    counterRotateActive = false;
    downActive = false;
    leftActive = false;
    rightActive = false;
    hardDownActive = false;
    swapHeldActive = false;

    for (GameInput input : gameInputs) {
      input.update();
      if (input.newGameActive) newGameActive = true;
      if (input.rotateActive) rotateActive = true;
      if (input.counterRotateActive) counterRotateActive = true;
      if (input.downActive) downActive = true;
      if (input.leftActive) leftActive = true;
      if (input.rightActive) rightActive = true;
      if (input.hardDownActive) hardDownActive = true;
      if (input.swapHeldActive) swapHeldActive = true;
    }
  }
}