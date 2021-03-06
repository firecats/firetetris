class KeyboardGameInput extends GameInput {

  KeyboardGameInput() {
    // Not available using standard keyboard mapping
    counterRotateActive = false;
  }

  public void keyPressed() {
    switch (keyCode) {
      case ENTER: case RETURN: startActive = true; break;
      case UP: upActive = rotateActive = menuUpActive = true; break;
      case DOWN: downActive = menuDownActive = true; break;
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
      case ENTER: case RETURN: startActive = false; break;
      case UP: upActive = rotateActive = menuUpActive = false; break;
      case DOWN: downActive = menuDownActive = false; break;
      case LEFT: leftActive = false; break;
      case RIGHT: rightActive = false; break;
      case SHIFT: swapHeldActive = false; break;
    }

    switch (key) {
      case ' ': hardDownActive = false; break;
    }
  }
}
