/*
 
*/

#include <Arduino_LSM6DS3.h>
#include <ArduinoBLE.h>

float x,y,z, mag;
int incomingByte = 0;
bool alert = false;

BLEService ledService("180A"); // BLE LED Service
BLEByteCharacteristic switchCharacteristic("2A57", BLERead | BLEWrite);


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

  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy failed!");
    while (1);
  }

  BLE.setLocalName("LED");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(switchCharacteristic);
  BLE.addService(ledService);
  switchCharacteristic.writeValue(0);
  BLE.advertise();
  Serial.println("BLE LED Peripheral");
  
}

void loop() {
  // listen for Bluetooth® Low Energy peripherals to connect:
  BLEDevice central = BLE.central();

  // if a central is connected to peripheral:
  if (central) {
  
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());

    while (central.connected()) {
      
      // checks if alert should be on
      if (alert)
        digitalWrite(LED_BUILTIN, HIGH);
      else
        digitalWrite(LED_BUILTIN, LOW);

      // disarm from app
      if (switchCharacteristic.written()) {
        if (!switchCharacteristic.value()) {   // value 0
          alert = false;         // will turn the LED off
        }
      }
        
      mag = getMag();
      
      // if magnitude is greater than threshold +- 4, turn alert on
      if (mag > 104.0 || mag < 96.0) {
        // arm
        Serial.println("alert");
        alert = true;
      } 
//      else if (Serial.available() > 0) {
//        incomingByte = Serial.read();
//        if (incomingByte == 65) {
//          // disarm
//          Serial.println("disarming");
//          alert = false;
//        }
//      }
    }
  }
  delay(100);
}

int getMag() {
  if (IMU.accelerationAvailable()) 
        IMU.readAcceleration(x, y, z);
  
  mag = sqrt(x*x + y*y + z*z);
      
  Serial.print("Mag:"); Serial.println(mag*100);

  return mag*100;
}
