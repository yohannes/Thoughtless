
/*
 * NoteDocument.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 1/27/17.
 * Copyright © 2017 Yohannes Wijaya. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

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
