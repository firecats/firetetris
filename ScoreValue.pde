class ScoreValue {
  public String displayName;

  ScoreValue(String displayName) {
    this.displayName = displayName;
  }

  String toString() {
    return "";
  }
}

class IntScoreValue extends ScoreValue {
  public int value;

  IntScoreValue(String displayName, int value) {
    super(displayName);
    this.value = value;
  }

  String toString() {
    return Integer.toString(value);
  }
}

class TimeScoreValue extends ScoreValue {
  public int seconds;

  TimeScoreValue(String displayName, int seconds) {
    super(displayName);
    this.seconds = seconds;
  }

  String toString() {
    int secs = seconds % 60;
    int mins = seconds / 60;
    return String.format("%02d:%02d", mins, secs);
  }
}