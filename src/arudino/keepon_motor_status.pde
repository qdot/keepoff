// Wire Master Writer
// by Nicholas Zambetti <http://www.zambetti.com>

// Demonstrates use of the Wire library
// Writes data to an I2C/TWI slave device
// Refer to the "Wire Slave Receiver" example for use with this

// Created 29 March 2006

// This example code is in the public domain.


#include <Wire.h>

void setup()
{
  Serial.begin(115200);

}

byte x = 0;

void loop()
{
  Serial.print("Waiting for power on");
  while(analogRead(0) < 512); 
  Serial.print("Pulling to ground");
  pinMode(A4, OUTPUT);
  digitalWrite(A4, LOW); 
  pinMode(A5, OUTPUT);
  digitalWrite(A5, LOW);
  delay(1000); 
  Serial.print("Floating");
  pinMode(A4, OUTPUT);
  digitalWrite(A4, HIGH);
  pinMode(A5, OUTPUT);
  digitalWrite(A5, HIGH);
  Serial.print("Starting comms");
  Wire.begin(); // join i2c bus (address optional for master)
  while(analogRead(0) > 512)
  {
    Serial.println("Running loop");
    Wire.requestFrom(85, 12);
    while(Wire.available())
    {
      Serial.println((int)Wire.receive());
    }
    /*
    Wire.beginTransmission((byte)82); // transmit to device #4
    Wire.send((byte)1);        // sends five bytes
    //Wire.send(0b10011100);        // sends five bytes
    Wire.send((byte)189);
    Serial.print("Status:");
    Serial.println((int)Wire.endTransmission());    // stop transmitting
*/
   delay(500);
  }
  Wire.close();
  /*
  Wire.requestFrom(85, 12);
  while(analogRead(0) > 512) {
    Serial.println((int)Wire.available());
  }
  */
}
