import hypermedia.net.*;

class UDPRenderer {
  
  private UDP udp;
  
  UDPRenderer(Config config) {
    udp = new UDP(this, config.backendPort);
    udp.log(true);     //printout the connection activity
    udp.listen(true);
  }
  
  void renderGameState(TetrisGame currentGame) {
    //println("UDP renderGameState");
  }
}
