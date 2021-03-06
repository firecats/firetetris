class GamepadGameInput extends GameInput {

  ControlIO control;
  ControlDevice gpad;

  GamepadGameInput(String config, PApplet applet) {
    control = ControlIO.getInstance(applet);
    // Find a device that matches the configuration file
    gpad = control.getMatchedDevice(config);

    startActive = false;
    rotateActive = false;
    counterRotateActive = false;
    upActive = false;
    downActive = false;
    leftActive = false;
    rightActive = false;
    hardDownActive = false;
    swapHeldActive = false;
    menuUpActive = false;
    menuDownActive = false;
  }

  public void update() {
    if (gpad == null) return;

    hardDownActive = gpad.getButton("START").pressed();
    rotateActive = gpad.getButton("A").pressed();
    counterRotateActive = gpad.getButton("B").pressed();
    downActive = gpad.getSlider("YPOS").getValue() > 0.5;
    leftActive = gpad.getSlider("XPOS").getValue() < -0.5;
    rightActive = gpad.getSlider("XPOS").getValue() > 0.5;
    upActive = gpad.getSlider("YPOS").getValue() < -0.5;
    swapHeldActive = gpad.getButton("SELECT").pressed();
  }
}
