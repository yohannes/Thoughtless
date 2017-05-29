
/*
 * Note.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 8/23/16.
 * Copyright © 2016 Yohannes Wijaya. All rights reserved.
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

import Foundation

class Note: NSObject, NSCoding {
    
    // MARK: - Stored Properties
    
    struct PropertyKey {
        static let entryKey = "entry"
        static let dateModificationTimeStampKey = ""
    }
    
    var entry: String
    var dateModificationTimeStamp: String
    
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
