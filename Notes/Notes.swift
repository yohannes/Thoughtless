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
    
    var entry: String
    
    // MARK: - Initialization
    
    init?(entry input: String) {
        if input.isEmpty {
            return nil
        }
        
        self.entry = input
    }
}
