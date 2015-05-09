class KeyboardGameInput extends GameInput {

  KeyboardGameInput() {
    // Not available using standard keyboard mapping
    counterRotateActive = false;
  }

  public void keyPressed() {
    switch (keyCode) {
      case UP: rotateActive = true; break;
      case DOWN: downActive = true; break;
      case LEFT: leftActive = true; break;
      case RIGHT: rightActive = true; break;
      case SHIFT: swapHeldActive = true; break;
    }

    switch (key) {
      case ' ': hardDownActive = true; break;
    }
  }

  public void keyReleased() {
    switch (keyCode) {
      case UP: rotateActive = false; break;
      case DOWN: downActive = false; break;
      case LEFT: leftActive = false; break;
      case RIGHT: rightActive = false; break;
      case SHIFT: swapHeldActive = false; break;
    }

    switch (key) {
      case ' ': hardDownActive = false; break;
    }
  }
}
