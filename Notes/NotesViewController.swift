//
//  NotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    // MARK: - Stored Properties
    
    var note: Notes?
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - IBAction Properties
    
    @IBAction func cancelButtonDidTouch(sender: UIBarButtonItem) {
        self.textView.resignFirstResponder()
        
        let isPresentingFromAddButton = self.presentingViewController is UINavigationController
        if isPresentingFromAddButton {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        if let validNote = self.note {
            self.textView.text = validNote.entry
        }
        
        self.textView.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let validBarButtonItem = sender as? UIBarButtonItem, validBarButtonItem === self.saveButton {
            let entry = self.textView.text ?? ""
            self.note = Notes(entry: entry)
        }
    }
}
