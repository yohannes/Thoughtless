//
//  Note.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 8/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation

class Note: NSObject, NSCoding {
    
    // MARK: - Stored Properties
    
    struct PropertyKey {
        static let entryKey = "entry"
        static let dateModificationTimeStampKey = ""
    }
    
    var entry: String
    var dateModificationTimeStamp: String
    
    static var DocumentsDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static let archiveURL = Note.DocumentsDirectory.appendingPathComponent("notes")
    
    // MARK: - Initialization
    
    init?(entry input: String, dateOfCreation timeStamp: String) {
        guard !input.isEmpty || !timeStamp.isEmpty else { return nil }
        
        self.entry = input
        self.dateModificationTimeStamp = timeStamp
        
        super.init()
    }
    
    // MARK: - NSCoding Methods
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let validEntry = aDecoder.decodeObject(forKey: PropertyKey.entryKey) as? String else { return nil }
        guard let validDate = aDecoder.decodeObject(forKey: PropertyKey.dateModificationTimeStampKey) as? String else { return nil }
        self.init(entry: validEntry, dateOfCreation: validDate)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.entry, forKey: PropertyKey.entryKey)
        aCoder.encode(self.dateModificationTimeStamp, forKey: PropertyKey.dateModificationTimeStampKey)
    }
}
