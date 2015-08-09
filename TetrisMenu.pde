class TetrisMenu extends InputHandler implements ControlListener {

  public void start() {
    if (currentGame != null && currentGame.isPaused()) {
      currentGame.setPaused(false);
    } else {
      newGame();
    }
  }

  public void down() {}
  public void left() {}
  public void right() {}

  private void newGame() {
    minim.stop();
    currentGame = new TetrisGame(minim);
    currentGame.addMod(new TimedMode(1000 * 60 * 3));
  }

  @Override
  public void controlEvent(ControlEvent event) {
    if (event.name() == "play") {
      newGame();
    }
  }
}