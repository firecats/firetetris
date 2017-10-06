class Audio {

  AudioPlayer music;
  AudioSample selectionImproved, rotate, place, line, tetris;
  MusicLibrary library;
  boolean loopSingleTrack = false;
  boolean paused = false;

  Audio(Minim minim) {
    library = new MusicLibrary();
    
    selectionImproved = minim.loadSample("selection_improved.wav");
    selectionImproved.setGain(30);
    rotate = minim.loadSample("rotate.aif");
    rotate.setGain(5);
    place = minim.loadSample("place.aif");
    place.setGain(-5);
    line = minim.loadSample("line.aif");
    line.setGain(5);
    tetris = minim.loadSample("tetris.aif");
    tetris.setGain(10);
  }

  // Meant to be called at every frame
  public void update() {
    // Detect that the music has stopped
    if (music != null && !music.isPlaying() && !paused) {
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
    music.setGain(-10);
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

  public void pauseMusic() {
    if (music == null)
      return;

    paused = true;
    music.pause();
  }

  public void resumeMusic() {
    if (music == null)
      return;

    paused = false;
    music.play();
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
