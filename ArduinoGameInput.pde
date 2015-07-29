import processing.serial.*;
import cc.arduino.*;

class ArduinoGameInput extends GameInput {

  Arduino arduino;
  ControlIO control;
  
  ArduinoGameInput(String config, PApplet applet) {
    control = ControlIO.getInstance(applet);
    println(Arduino.list());

    arduino = new Arduino(applet, config, 57600);

    // Set the Arduino digital pins as inputs.
    for (int i = 0; i <= 13; i++)
      arduino.pinMode(i, Arduino.INPUT);

    rotateActive = false;
    counterRotateActive = false;
    downActive = false;
    leftActive = false;
    rightActive = false;
    hardDownActive = false;
    swapHeldActive = false;
  }

  public void update() {
    if (arduino == null) return;

    rotateActive = (arduino.digitalRead(5) == Arduino.HIGH);
    downActive = (arduino.digitalRead(3) == Arduino.HIGH);
    leftActive = (arduino.digitalRead(2) == Arduino.HIGH);
    rightActive = (arduino.digitalRead(4) == Arduino.HIGH);
  }
}
