//
//  ViewController.swift
//  Cup Protector App
//
//  Created by Carmen Lee on 4/17/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {

    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    // Objects
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var ArmButton: UIButton!
    @IBOutlet weak var DisarmButton: UIButton!
    @IBOutlet weak var DisconnectButton: UIButton!
    
    // Characteristics
    private var toggle: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        StatusLabel.text = "Hello"
    }
    
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.arduinoUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.arduinoUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)

    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            StatusLabel.text = "Connected"
            print("Connected to your Arduino")
            peripheral.discoverServices([ParticlePeripheral.arduinoUUID])
            
            ConnectButton.isEnabled = false
            DisconnectButton.isEnabled = true
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.arduinoUUID {
                    print("Service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.readwriteUUID], for: service)
                    return
                }
            }
        }
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.readwriteUUID {
                    print("Read/Write value characteristic found")
                    ArmButton.isEnabled = false     // currently has no action
                    DisarmButton.isEnabled = true
                    toggle = characteristic
                }
            }
        }
    }
    
    // starts finding service when pressed
    @IBAction func ConnectButton(_ sender: Any) {
        StatusLabel.text = "Finding device..."
        centralManager = CBCentralManager(delegate: self, queue: nil);
    }
    
    @IBAction func ArmButton(_ sender: Any) {
        // doesn't do anything right now
    }
    
    // turn light off when pressed
    @IBAction func DisarmButton(_ sender: Any) {
        let bytes : [UInt8] = [ 0x00 ]      // hex value of 0(src.ino) will turn the light off
        let data = NSData(bytes: bytes, length: bytes.count)
        peripheral.writeValue(data as Data, for: toggle!, type: CBCharacteristicWriteType.withResponse)

    }
    
    // disconnects device
    @IBAction func DisconnectButton(_ sender: Any) {
        StatusLabel.text = "Disconnecting..."
        centralManager.cancelPeripheralConnection(peripheral)
        
        print("Disconnected")
        StatusLabel.text = "Hello"
        self.peripheral = nil
        
        ConnectButton.isEnabled = true
        ArmButton.isEnabled = false
        DisarmButton.isEnabled = false
        DisconnectButton.isEnabled = false
        
    }
    
    // need notification to check if ble connection is still alive

    
};

