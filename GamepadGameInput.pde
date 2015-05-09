class GamepadGameInput extends GameInput {

  ControlIO control;
  ControlDevice gpad;

  GamepadGameInput(PApplet applet) {
    control = ControlIO.getInstance(applet);
    // Find a device that matches the configuration file
    gpad = control.getMatchedDevice("nes_controller");

    rotateActive = false;
    counterRotateActive = false;
    downActive = false;
    leftActive = false;
    rightActive = false;
    hardDownActive = false;
    swapHeldActive = false;
  }

  public void update() {
    if (gpad == null) return;

    rotateActive = gpad.getButton("A").pressed();
    counterRotateActive = gpad.getButton("B").pressed();
    downActive = gpad.getSlider("YPOS").getValue() > 0.5;
    leftActive = gpad.getSlider("XPOS").getValue() < -0.5;
    rightActive = gpad.getSlider("XPOS").getValue() > 0.5;
    hardDownActive = gpad.getSlider("YPOS").getValue() < -0.5;
    swapHeldActive = gpad.getButton("SELECT").pressed();
  }
}
