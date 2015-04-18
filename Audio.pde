class Audio {
  
  AudioPlayer music;
  
  AudioSample rotate, place, line;
  
  Audio(Minim minim) {
    music = minim.loadFile("Tetris_theme.mp3");
    music.loop();
    
    rotate = minim.loadSample("rotate.wav");
    place = minim.loadSample("place.wav");
    line = minim.loadSample("line.wav");
  }
  
  public void playMusic() {
    music.rewind();
    music.play();
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
  
  public void playPlace() {
    place.trigger();
  }
}
