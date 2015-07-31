class GameMod {

  protected TetrisGame game;

  public void initialize(TetrisGame game) {
    this.game = game;
  }

  public void update() {

  }

}

// TimedMode will automatically end the game after a predetermined set of time. This time is specified
// at construction time in milliseconds.
class TimedMode extends GameMod {
  private int startTime;
  private int gameDuration;
  private ScoreValue timer = new ScoreValue("TIME", 0);

  TimedMode(int gameDuration) {
    this.gameDuration = gameDuration;
  }

  public void initialize(TetrisGame game) {
    super.initialize(game);
    this.startTime = millis();
    game.addScoreValue(timer);
  }

  public void update() {
    timer.value = (gameDuration - (millis() - startTime)) / 1000;
    if (timer.value < 0) timer.value = 0;
    if (game != null && timer.value == 0) game.endGame();
  }
}