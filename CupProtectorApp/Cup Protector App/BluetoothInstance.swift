//
//  BluetoothInstance.swift
//  Cup Protector App
//
//  Created by Carmen Lee on 5/4/22.
//

import Foundation
import CoreBluetooth

class BluetoothInstance: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.ledServiceUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.ledServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)

    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            StatusLabel.text = "Connected"
            print("Connected to your Arduino")
            print(peripheral)
            peripheral.discoverServices([ParticlePeripheral.ledServiceUUID, ParticlePeripheral.batteryServiceUUID])
            
            ConnectButton.isEnabled = false
            DisconnectButton.isEnabled = true
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.ledServiceUUID {
                    print("Read/Write Service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.readwriteCharacteristicUUID], for: service)
//                    return
                }
                if service.uuid == ParticlePeripheral.batteryServiceUUID {
                    print("Battery Service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.batteryCharacteristicUUID], for: service)
//                    return
                }
            }
        }
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.readwriteCharacteristicUUID {
                    print("Read/Write value characteristic found")
                    ArmButton.isEnabled = false     // currently has no action
                    DisarmButton.isEnabled = true
                    toggle = characteristic
                }
                else if characteristic.uuid == ParticlePeripheral.batteryCharacteristicUUID {
                    print("Battery characteristic found")
                    battChar = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)

                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if( characteristic == battChar ) {
            BatteryPercentageLabel.text = "\(characteristic.value![0])%"
            return characteristic.value![0]
        }

    }

};

let sharedBluetoothInstance = BluetoothInstance()

