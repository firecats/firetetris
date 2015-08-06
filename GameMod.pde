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
  private TimeScoreValue timer = new TimeScoreValue("TIME", 0);

  TimedMode(int gameDuration) {
    this.gameDuration = gameDuration;
  }

  public void initialize(TetrisGame game) {
    super.initialize(game);
    this.startTime = millis();
    game.addScoreValue(timer);
  }

  public void update() {
    timer.seconds = (gameDuration - (millis() - startTime)) / 1000;
    if (timer.seconds < 0) timer.seconds = 0;
    if (game != null && timer.seconds == 0) game.endGame();
  }
}