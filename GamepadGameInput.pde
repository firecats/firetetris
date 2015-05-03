class GamepadGameInput extends GameInput {

  ControlIO control;
  ControlDevice gpad;

  GamepadGameInput(PApplet applet) {
    control = ControlIO.getInstance(applet);
    // Find a device that matches the configuration file
    gpad = control.getMatchedDevice("nes_controller");
  }

  public void update() {
    rotateActive = gpad.getSlider("YPOS").getValue() < -0.5;
    downActive = gpad.getSlider("YPOS").getValue() > 0.5;
    leftActive = gpad.getSlider("XPOS").getValue() < -0.5;
    rightActive = gpad.getSlider("XPOS").getValue() > 0.5;
    hardDownActive = gpad.getButton("A").pressed();
    swapHeldActive = gpad.getButton("B").pressed();
  }
}
