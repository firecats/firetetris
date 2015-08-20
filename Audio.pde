class Audio {

  AudioPlayer music;
  AudioSample selectionImproved, rotate, place, line, tetris;
  MusicLibrary library;
  boolean loopSingleTrack = false;

  Audio(Minim minim) {
    library = new MusicLibrary();
    
    selectionImproved = minim.loadSample("selection_improved.wav");
    rotate = minim.loadSample("rotate.wav");
    place = minim.loadSample("place.wav");
    line = minim.loadSample("line.wav");
    tetris = minim.loadSample("tetris.wav");
  }

  // Meant to be called at every frame
  public void update() {
    // Detect that the music has stopped
    if (music != null && !music.isPlaying()) {
      if (loopSingleTrack) {
        music.rewind();
        music.play();
      }
      else {
        playNextMusic();
      }
    }
  }

  public void playMusic() {
    if (music != null)
      return;

    playNextMusic();
  }
  
  public void playNextMusic() {
    if (music != null && music.isPlaying())
      stopMusic();

    music = minim.loadFile(library.getNextFile());
    music.play();
  }

  public String getCurrentMusic() {
    return library.getCurrentFileShortName();
  }

  public void toggleLoopSingleTrackMode() {
    loopSingleTrack = !loopSingleTrack;
  }

  public boolean isLoopSingleTrackMode() {
    return loopSingleTrack;
  }

  public void toggleShuffleMode() {
    library.setShuffleMode(! library.isShuffleMode());
  }

  public boolean isShuffleMode() {
    return library.isShuffleMode();
  }

  public void stopMusic() {
    if (music == null)
      return;

    music.close();
    music = null;
  }

  public void playSelectionImproved() {
    selectionImproved.trigger();
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
