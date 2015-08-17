import java.io.*;
import java.util.Arrays;

class MusicLibrary implements FilenameFilter {

  final public  String[] SUPPORTED_EXTENSIONS = new String[] { ".mp3" };
  final private int NO_FILE     = -1;
  final private File _musicDir;

  boolean   _shuffleMode        = true;
  String[]  _musicDirContents   = null;
  int[]     _shuffleOrder       = null;
  int       _currentFile        = NO_FILE;
    

  public MusicLibrary() {
    String musicPath = dataPath(Config.musicPath);
    _musicDir = new File(musicPath);
    loadMusicSelection();
  }

  public void setShuffleMode(boolean enabled) {
    
    if (_shuffleOrder == null) {
      _shuffleOrder = generateShuffleOrder();
    }

    if (_shuffleMode != enabled)
    {
      _shuffleMode = enabled;

      // Keep same "current file"
      if (!_shuffleMode) {
        _currentFile = _shuffleOrder[_currentFile];
      } else {
        int positionOfCurrentFileInShuffleOrder = 0;
        while (_shuffleOrder[positionOfCurrentFileInShuffleOrder] != _currentFile)
          ++positionOfCurrentFileInShuffleOrder;
        _currentFile = positionOfCurrentFileInShuffleOrder;
      }
    }
  }

  public boolean isShuffleMode() {
    return _shuffleMode;
  }

  public String getCurrentFileShortName() {
    if (_currentFile == NO_FILE)
      return "";

    int indexIntoFilenameArray = _shuffleMode? _shuffleOrder[_currentFile]: _currentFile;
    String filename = _musicDirContents[indexIntoFilenameArray];
    return filename.substring(0,filename.indexOf("."));
  }

  public String getNextFile() {
    // Sanity check
    if (_musicDirContents == null)
      loadMusicSelection();

    if (++_currentFile >= _musicDirContents.length) {
      _currentFile = 0;
      // Refresh so that we can "grab" newly added music and include it
      // into the playlist automatically
      loadMusicSelection();
    }

    // Get our next bucket of shuffled files if needed
    if (_currentFile == 0 && _shuffleMode) {
      _shuffleOrder = generateShuffleOrder();
    }

    int indexIntoFilenameArray = _shuffleMode? _shuffleOrder[_currentFile]: _currentFile;
    
    return new File( Config.musicPath, _musicDirContents[indexIntoFilenameArray] ).getPath();
  }

  // Generates a random order in which to play the files
  protected int[] generateShuffleOrder() {
    // Sanity check
    if (_musicDirContents == null)
      loadMusicSelection();

    // Array to be returned by this method
    int[] result = new int[_musicDirContents.length];

    IntList pool = new IntList();
    for (int i=0; i<_musicDirContents.length; ++i) {
      pool.append(i);
    }

    // This generates a random music selection with the added
    // constraint that the first selection in the shuffle
    // cannot be the currently playing file, to prevent repeats
    for (int i=0; i<_musicDirContents.length; ++i) {
      int selection;
      do {
        selection = int(random(pool.size()));
      }
      while (i == 0 && selection == _currentFile );
      result[i] = (int) pool.remove(selection);
    }
    
    return result;
  }

  protected void loadMusicSelection() {
    if (_musicDir.exists() && _musicDir.isDirectory()) {
      _musicDirContents = _musicDir.list(this);

      if (_musicDirContents.length == 0) {
        throw new AssertionError("Directory " + _musicDir.getAbsolutePath() + " doesn't contain any music!");  
      }
    }
    else {
      throw new AssertionError("Directory " + _musicDir.getAbsolutePath() + " nonexistent. Cannot load music.");
    }
  }

  // FileFilter interface implementation START ---------------
  // Used by File.listFiles() from loadMusicSelection()

  boolean accept(File dir, String name) {
    String extension = name.substring(name.lastIndexOf("."));

    return Arrays.asList(SUPPORTED_EXTENSIONS).contains(extension.toLowerCase());
  }

  // FileFilter interface implementation END -----------------

}