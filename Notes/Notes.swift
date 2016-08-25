//
//  Notes.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation

class Notes: NSObject, NSCoding {
    
    // MARK: - Stored Properties
    
    struct PropertyKey {
        static let entryKey = "entry"
    }
    
    var entry: String
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
    static let archiveURL = Notes.DocumentsDirectory.URLByAppendingPathComponent("notes")
    
    // MARK: - Initialization
    
    init?(entry input: String) {
        if input.isEmpty {
            return nil
        }
        
        self.entry = input
        
        super.init()
    }
    
    // MARK: - NSCoding Methods
    
    required convenience init?(coder aDecoder: NSCoder) {
        let entry = aDecoder.decodeObjectForKey(PropertyKey.entryKey) as! String
        self.init(entry: entry)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.entry, forKey: PropertyKey.entryKey)
    }
}
