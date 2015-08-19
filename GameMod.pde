class GameMod {

  protected TetrisGame game;

  public void initialize(TetrisGame game) {
    this.game = game;
  }

  public void update() {}
  public void setPaused(boolean paused) {}
}

// TimedMode will automatically end the game after a predetermined set of time. This time is specified
// at construction time in milliseconds.
class TimedMode extends GameMod {
  private int startTime;
  private int gameDuration;
  private boolean ended;
  private TimeScoreValue timer = new TimeScoreValue("TIME", 0);

  TimedMode(int gameDuration) {
    this.gameDuration = gameDuration;
    this.ended = false;
  }

  public void initialize(TetrisGame game) {
    super.initialize(game);
    this.startTime = millis();
    game.addScoreValue(timer);
  }

  public void update() {
    timer.seconds = (gameDuration - (millis() - startTime)) / 1000;
    if (timer.seconds < 0) timer.seconds = 0;
    if (game != null && timer.seconds == 0 && !ended) {
      ended = true;
      game.audio.playSelectionImproved();
      game.transitionToProvider(new ToughestNextPieceProvider(game));
    }
  }

  public void setPaused(boolean paused) {
    if (paused) {
      // Save how much time is really left right now
      this.gameDuration = (gameDuration - (millis() - startTime));
    } else {
      // Reset the start point
      this.startTime = millis();
    }
  }
}