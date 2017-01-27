//
//  NotesDocument.swift
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
        if let validNote = unarchiver.decodeObject(forKey: self.archiveKey) as? Note {
            self.note = validNote
            unarchiver.finishDecoding()
        }
        else {
            self.note = Note(entry: "Hello Sunshine! Come & tap me first!\n👇👇👇\n\nYou can power up your note by writing your words like **this** or _this_, create an [url link](http://apple.com), or even make a todo list:\n\n* Watch WWDC videos.\n* Write `code`.\n* Fetch my girlfriend for a ride.\n* Refactor `code`.\n\nOr even create quote:\n\n> A block of quote.\n\nTap *Go!* to preview your enhanced note.\n\nTap *How?* to learn more.", dateOfCreation: CurrentDateAndTimeHelper.get())
        }
    }

}
