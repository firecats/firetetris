import hypermedia.net.*;

class UDPRenderer {
  
  private UDP udp;
  private Config config;
  private Grid grid;
  private int pooferStartTime = 0;
  
  UDPRenderer(Config config) {
    this.config = config;
    
    udp = new UDP(this);
    //udp.log(true);     //printout the connection activity
  }
  
  void renderGameState(TetrisGame currentGame) {
    Packet packet = new Packet(this.config.protocolVersion, TETRIS_WIDTH, TETRIS_HEIGHT);

    if (currentGame == null || currentGame.isGameOver()) {
      packet.addPoofer(false);
      packet.emptyGrid();
    } else {
      int currentMillis = millis();
      if (currentGame.getJustScoredSpecial())
        pooferStartTime = currentMillis;
      packet.addPoofer(pooferStartTime > 0 && (currentMillis < pooferStartTime + config.pooferDurationMs));

      Tetromino current = currentGame.getCurrent();
      
      boolean[][] flattenGrid = new boolean[TETRIS_WIDTH][TETRIS_HEIGHT];
      
      setGridData(flattenGrid, currentGame.getGrid());
      
      if(current != null) 
        setShapeData(flattenGrid, current.shape, current.x, current.y);
      
      packet.addGridData(flattenGrid);
    }
    
    this.send(packet);
  }
  
  private void setGridData(boolean[][] flattenGrid, Grid grid) {
    for (int i = 0; i < grid.cols; ++i) 
      for (int j = 0; j < grid.rows; ++j)
        flattenGrid[i][j] = grid.colors[i][j] != 0 ? true : false;
  }
  
  private void setShapeData(boolean[][] flattenGrid, Shape shape, int x, int y) {
    for (int i = 0; i < shape.matrix.length; ++i) {
      for (int j = 0; j < shape.matrix.length; ++j) {
        if (shape.matrix[i][j] && x + i >= 0 && y + j>= 0) {
          flattenGrid[x + i][y + j] = true;
        }
      }
    }
  }
  
  private void send(Packet packet) {
    //println(packet.getData()); //for debug only
    udp.send(packet.getData(), this.config.backendIp, this.config.backendPort);
  }
}
