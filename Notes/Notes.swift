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
    
    static var DocumentsDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static let archiveURL = Notes.DocumentsDirectory.appendingPathComponent("notes")
    
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
        let entry = aDecoder.decodeObject(forKey: PropertyKey.entryKey) as! String
        self.init(entry: entry)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.entry, forKey: PropertyKey.entryKey)
    }
}
