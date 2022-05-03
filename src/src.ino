/*
 
*/

#include <Arduino_LSM6DS3.h>
#include <ArduinoBLE.h>

// LED
BLEService ledService("b244ec7e-2957-4b0f-93a4-e5fa3d13a492"); // BLE LED Service
BLEByteCharacteristic switchCharacteristic("2A57", BLERead | BLEWrite);
float x,y,z, mag;
int incomingByte = 0;
bool alert = false;

// Battery
BLEService batteryService("0be835fe-9b27-41b5-821c-8f6ee85105d6");
BLEUnsignedCharCharacteristic batteryLevelChar("2A19",  // standard 16-bit characteristic UUID
    BLERead | BLENotify); // remote clients will be able to get notifications if this characteristic changes
int oldBatteryLevel = 0;  // last battery level reading from analog input
long previousMillis = 0;  // last time the battery level was checked, in ms


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

  BLE.setLocalName("Cup Protector");
  
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(switchCharacteristic);
  BLE.addService(ledService);
  switchCharacteristic.writeValue(0);
  
//  BLE.setAdvertisedService(batteryService); // add the service UUID
  batteryService.addCharacteristic(batteryLevelChar); // add the battery level characteristic
  BLE.addService(batteryService); // Add the battery service
  batteryLevelChar.writeValue(oldBatteryLevel); // set initial value for this characteristic
  
  BLE.advertise();
  Serial.println("BLE Peripheral");
  
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

//       disarm from app
      if (switchCharacteristic.written()) {
        if (!switchCharacteristic.value()) {   // value 0
          alert = false;         // will turn the LED off
        }
      }

      long currentMillis = millis();
      // if 200ms have passed, check the battery level:
      if (currentMillis - previousMillis >= 200) {
        previousMillis = currentMillis;
        updateBatteryLevel();
      }
        
      mag = getMag();
      
      // if magnitude is greater than threshold +- 4, turn alert on
      if (mag > 104.0 || mag < 96.0) {
        // arm
        Serial.println("alert");
        alert = true;
      } 

    }
  }
  else {
    Serial.println("Disconnected...");
  }
  delay(100); // how will delay affect alert
}


int getMag() {
  if (IMU.accelerationAvailable()) 
        IMU.readAcceleration(x, y, z);
  
  mag = sqrt(x*x + y*y + z*z);
      
  Serial.print("Mag:"); Serial.println(mag*100);
  return mag*100;
}

void updateBatteryLevel() {
  /* Read the current voltage level on the A0 analog input pin.
     This is used here to simulate the charge level of a battery.
  */
  int battery = analogRead(A0);
  int batteryLevel = map(battery, 0, 1023, 0, 100);

  if (batteryLevel != oldBatteryLevel) {      // if the battery level has changed
    Serial.print("Battery Level % is now: "); // print it
    Serial.println(batteryLevel);
    batteryLevelChar.writeValue(batteryLevel);  // and update the battery level characteristic
    oldBatteryLevel = batteryLevel;           // save the level for next comparison
  }
}
