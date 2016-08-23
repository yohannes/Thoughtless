//
//  NotesTests.swift
//  NotesTests
//
//  Created by Yohannes Wijaya on 8/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import XCTest

class NotesTests: XCTestCase {
    
    // Test to confirm that the Notes initializer returns when no string input is provided
    
    func testNotesInitialization() {
        
        // Success case
        let successNotesInitialization = Notes(entry: "hello world. This is my first note!")
        XCTAssertNotNil(successNotesInitialization)
        
        // Failure case
        let failureNotesInitialization = Notes(entry: "")
        XCTAssertNil(failureNotesInitialization)
    }
    
}
