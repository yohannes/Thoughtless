//
//  NoteDocument.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 1/27/17.
//  Copyright © 2017 Yohannes Wijaya. All rights reserved.
//

import UIKit

class NoteDocument: UIDocument {
    
    // MARK: - Stored Properties
    
    var note: Note!
    let archiveKey = "Note"
    
    // MARK: - UIDocument Methods
    
    override func contents(forType typeName: String) throws -> Any {
        let mutableData = NSMutableData()
        let archiver = NSKeyedArchiver.init(forWritingWith: mutableData)
        archiver.encode(self.note, forKey: self.archiveKey)
        archiver.finishEncoding()
        return mutableData
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        let unarchiver = NSKeyedUnarchiver.init(forReadingWith: contents as! Data)
        guard let validNote = unarchiver.decodeObject(forKey: self.archiveKey) as? Note else { return }
        self.note = validNote
        unarchiver.finishDecoding()
    }
}
