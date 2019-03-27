//
//  Computer.swift
//  BluetoothLaptop
//
//  Created by Patty Case on 3/26/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit

class Computer : NSObject, NSCoding {
    
    //MARK: Properties
    
    var dateAdded: String
    var MACAddress: String
    var image: UIImage?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("computers")
    
    //MARK: Types
    
    struct PropertyKey {
        static let dateAdded = "dateAdded"
        static let MACAddress = "MACAddress"
        static let image = "image"
    }
    
    //MARK: Initialization
    
    init?(dateAdded: String, MACAddress: String, image: UIImage?) {
        
        // Initialize stored properties.
        self.dateAdded = dateAdded
        self.MACAddress = MACAddress
        self.image = image
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dateAdded, forKey: PropertyKey.dateAdded)
        aCoder.encode(MACAddress, forKey: PropertyKey.MACAddress)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let MACAddress = aDecoder.decodeObject(forKey: PropertyKey.MACAddress) as? String else {
            print("Unable to decode the MAC address for a Computer object.")
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        
        let dateAdded = aDecoder.decodeObject(forKey: PropertyKey.dateAdded) as? String
        
        // Must call designated initializer.
        self.init(dateAdded: dateAdded ?? "", MACAddress: MACAddress, image: image)
        
    }
}

