/*
  Arduino LSM6DS3 - Accelerometer Application

  This example reads the acceleration values as relative direction and degrees,
  from the LSM6DS3 sensor and prints them to the Serial Monitor or Serial Plotter.

  The circuit:
  - Arduino Nano 33 IoT

  Created by Riccardo Rizzo

  Modified by Jose García
  27 Nov 2020

  This example code is in the public domain.
*/

#include <Arduino_LSM6DS3.h>

float x,y,z;
//int degreesX = 0;
int degreesz = 0;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  
  Serial.begin(9600);
  while (!Serial);
  Serial.println("Started");

  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
//
//  Serial.print("Accelerometer sample rate = ");
//  Serial.print(IMU.accelerationSampleRate());
//  Serial.println("Hz");
}

void loop() {

  if (IMU.accelerationAvailable()) {
    IMU.readAcceleration(x, y, z);

  }
  
//  Serial.print("x: ");
//  Serial.print("X:"); Serial.print(x);Serial.print(",");
//  Serial.print("Y:"); Serial.print(y);Serial.print(",");
//  Serial.print("Z:"); Serial.print(z);Serial.print(",");

  float mag;
  mag = sqrt(x*x + y*y + z*z);
  Serial.print("Mag:"); Serial.println(mag*100);

   // threshold +- 4
  if (mag*100 > 104.0 || mag*100 < 96.0){
    Serial.println("alert");
    digitalWrite(LED_BUILTIN, HIGH);
  } else {
    Serial.println("good :)");
    digitalWrite(LED_BUILTIN, LOW);
  }
  

//  Serial.print("y: ");
//  Serial.println(y);
//
//  Serial.print("z: ");
//  Serial.println(z);
  delay(10);
}
