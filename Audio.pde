class Audio {
  
  AudioPlayer music;
  
  AudioSample rotate, place, line, tetris;
  
  Audio(Minim minim) {
    music = minim.loadFile("placeholder.mp3");
    music.setGain(-15);

    rotate = minim.loadSample("rotate.aif");
    place = minim.loadSample("place.aif");
    line = minim.loadSample("line.aif");
    tetris = minim.loadSample("tetris.aif");
  }
  
  public void playMusic() {
    music.rewind();
    music.loop();
  }
  
  public void stopMusic() {
    music.pause();
  }
  
  public void playRotate() {
    rotate.trigger();
  }
  
  public void playLine() {
    line.trigger();
  }
  
  public void playTetris() {
    tetris.trigger();
  }
  
  public void playPlace() {
    place.trigger();
  }
}
