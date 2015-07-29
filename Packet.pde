class Packet { 
  private String packet;
  
  private int width;
  private int height;
  
  Packet(int version, int width, int height) {
    this.packet = "";
    this.width = width;
    this.height = height;
    
    packet += version + "\n";
    packet += width + "\n";
    packet += height + "\n";
  }

  void addPoofer(boolean active) {
    for (int i = 0; i < this.width; ++i) {
      packet += active ? "1" : "0";
    }
    packet += "\n";
  }
  
  void addGridData(boolean[][] gridData) {
    for (int i = 0; i < this.height; ++i) {
      String rowData = "";
      
      for (int j = 0; j < this.width; ++j) {
        rowData += gridData[j][i] == true ? 1 : 0;
      }
      
      packet+=rowData + "\n";
    }
  }
  
  void emptyGrid() {
    this.addGridData(new boolean[this.width][this.height]);
  }
  
  String getData() {
    return this.packet;
  }
}
