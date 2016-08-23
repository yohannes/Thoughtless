//
//  Notes.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation

class Notes {
    
    // MARK: - Stored Properties
    
    var note: String
    
    // MARK: - Initialization
    
    init?(entry note: String) {
        if note.isEmpty {
            return nil
        }
        
        self.note = note
    }
}
