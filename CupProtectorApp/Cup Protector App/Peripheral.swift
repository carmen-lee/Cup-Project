//
//  Peripheral.swift
//  Cup Protector App
//
//  Created by Carmen Lee on 4/17/22.
//

import Foundation
import UIKit
import CoreBluetooth

class ParticlePeripheral: NSObject {
    
    public static let ledServiceUUID                    = CBUUID.init(string: "b244ec7e-2957-4b0f-93a4-e5fa3d13a492")
    public static let readwriteCharacteristicUUID       = CBUUID.init(string: "2A57")
    
    // battery
    public static let batteryServiceUUID         = CBUUID.init(string: "0be835fe-9b27-41b5-821c-8f6ee85105d6")
    public static let batteryCharacteristicUUID  = CBUUID.init(string: "2a19")

}
