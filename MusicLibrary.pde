import java.io.*;
import java.util.Arrays;

class MusicLibrary implements FilenameFilter {

  /** What filetypes are supported*/
  final public  String[] SUPPORTED_EXTENSIONS = new String[] { ".mp3" };

  /** Constant signifying an invalid array index */
  final private int NO_FILE     = -1;
  /** Directory where the music files lived, from Config.pde */
  final private File _musicDir;

  /** Is shuffle mode on? If not, we just loop through the files in 
  * filesystem (alphabetical-ish) order */
  boolean   _shuffleMode        = true;
  /* List of filenames representing the content of the music directory */
  String[]  _musicDirContents   = null;
  /* List of int which represent indices into _musicDirContents; 
   * randomly shuffled */
  int[]     _shuffleOrder       = null;
  /* Current index into _shuffleOrder or _musicDirContents, depending
  * on whether we are in Shuffle Mode or not */
  int       _currentFile        = NO_FILE;
    

  /** Builds the MusicLibrary. 
  * 
  * NOTE: Assumes there is at least one music file in the music directory!
  */
  public MusicLibrary() {
    String musicPath = dataPath(Config.musicPath);
    _musicDir = new File(musicPath);
    loadMusicSelection();
  }

  /** Toggles shufle mode on/off */
  public void setShuffleMode(boolean enabled) {
    
    if (_shuffleOrder == null) {
      _shuffleOrder = generateShuffleOrder();
    }

    if (_shuffleMode != enabled)
    {
      _shuffleMode = enabled;

      // We want to keep the same "current file" when we toggle
      // shuffle mode, so we have to recalculate the index to point
      // in the right array (the shuffle bucket, or directly in the
      // filename array)
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

  /** Gets the name of the currently playing file, with no extension.
  *   Intended for display.
  */
  public String getCurrentFileShortName() {
    if (_currentFile == NO_FILE)
      return "";

    int indexIntoFilenameArray = _shuffleMode? _shuffleOrder[_currentFile]: _currentFile;
    String filename = _musicDirContents[indexIntoFilenameArray];
    return filename.substring(0,filename.indexOf("."));
  }

  /** Selects the next file to be played and returns its name relative
   *  to the data directory */
  public String getNextFile() {

    // Sanity check
    if (_musicDirContents == null)
      loadMusicSelection();

    // Did we play through everything already? Reset.
    if (++_currentFile >= _musicDirContents.length) {
      _currentFile = 0;
      // Refresh so that we can "grab" music newly dropped into the
      // data folder and merge it into the playlist without restarting
      // the game
      loadMusicSelection();
    }

    // Get our next bucket of shuffled files if needed
    if (_currentFile == 0 && _shuffleMode) {
      _shuffleOrder = generateShuffleOrder();
    }

    int indexIntoFilenameArray = _shuffleMode? _shuffleOrder[_currentFile]: _currentFile;
    return new File( Config.musicPath, _musicDirContents[indexIntoFilenameArray] ).getPath();
  }

  // Generates a random permutation / order in which to play the files
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
      while (i == 0 && selection == _currentFile && pool.size() > 1);
      result[i] = (int) pool.remove(selection);
    }
    
    return result;
  }

  /** Initializes _musicDirContents based on the contents of the filesystem */
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

  /** Determines which names are acceptable music filenames */
  boolean accept(File dir, String name) {
    
    int dotIndex = name.lastIndexOf(".");
    if (dotIndex<=0)
      return false;

    String extension = name.substring(dotIndex);

    return new File(dir.getAbsolutePath(), name).isFile() && 
      Arrays.asList(SUPPORTED_EXTENSIONS).contains(extension.toLowerCase());
  }

  // FileFilter interface implementation END -----------------

}