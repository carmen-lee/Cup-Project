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
    
    public static let arduinoUUID     = CBUUID.init(string: "b244ec7e-2957-4b0f-93a4-e5fa3d13a492")
    public static let readwriteUUID     = CBUUID.init(string: "2A57")

}
