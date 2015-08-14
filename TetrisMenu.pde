class TetrisMenu extends InputHandler implements ControlListener {

  private int gameDuration;

  TetrisMenu() {
    gameDuration = 3;
  }

  public String getCurrentOptionDisplayName() { return "Time (mins)"; }
  public String getCurrentOptionValue() { return gameDuration > 0 ? Integer.toString(gameDuration) : "Infinite"; }
  public boolean canIncreaseCurrentOption() { return true; }
  public boolean canDecreaseCurrentOption() { return gameDuration > 0; }

  public void start() {
    if (currentGame != null && currentGame.isPaused()) {
      currentGame.setPaused(false);
    } else {
      newGame();
    }
  }

  public void up() {
    gameDuration++;
  }

  public void down() {
    gameDuration = max(0, gameDuration - 1);
  }

  public void left() {}
  public void right() {}

  private void newGame() {
    minim.stop();
    currentGame = new TetrisGame(minim);
    if (gameDuration > 0) currentGame.addMod(new TimedMode(1000 * 60 * gameDuration));
  }

  @Override
  public void controlEvent(ControlEvent event) {
    if (event.name() == "play") {
      newGame();
    }
  }
}