class GameInput {
  public boolean startActive;
  public boolean rotateActive;
  public boolean counterRotateActive;
  public boolean upActive;
  public boolean downActive;
  public boolean leftActive;
  public boolean rightActive;
  public boolean hardDownActive;
  public boolean swapHeldActive;
  public boolean menuUpActive;
  public boolean menuDownActive;

  public void update() { }
}

class CompositeGameInput extends GameInput {
  public ArrayList<GameInput> gameInputs;

  public CompositeGameInput() {
    gameInputs = new ArrayList<GameInput>();
  }
  
  public void update() {
    startActive = false;
    rotateActive = false;
    counterRotateActive = false;
    upActive = false;
    downActive = false;
    leftActive = false;
    rightActive = false;
    hardDownActive = false;
    swapHeldActive = false;
    menuUpActive = false;
    menuDownActive = false;

    for (GameInput input : gameInputs) {
      input.update();
      if (input.startActive) startActive = true;
      if (input.rotateActive) rotateActive = true;
      if (input.counterRotateActive) counterRotateActive = true;
      if (input.upActive) upActive = true;
      if (input.downActive) downActive = true;
      if (input.leftActive) leftActive = true;
      if (input.rightActive) rightActive = true;
      if (input.hardDownActive) hardDownActive = true;
      if (input.swapHeldActive) swapHeldActive = true;
      if (input.menuUpActive) menuUpActive = true;
      if (input.menuDownActive) menuDownActive = true;
    }
  }
}