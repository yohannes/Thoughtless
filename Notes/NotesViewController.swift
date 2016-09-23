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
  
  @IBOutlet weak var textView: UITextView! {
    didSet {
      if let validNote = self.note {
        self.textView.text = validNote.entry
      }
    }
  }
  @IBOutlet weak var saveButton: UIBarButtonItem!
  
  // MARK: - IBAction Methods
  
  @IBAction func cancelButtonDidTouch(sender: UIBarButtonItem) {
    self.textView.resignFirstResponder()
    
    // Check the type of an object #1. More: http://stackoverflow.com/a/25345480/2229062
    print("I am of type: \(self.presentingViewController.self)")
    
    // Check the type of an object #2. More: http://stackoverflow.com/a/33001534/2229062
    if let unknown: AnyObject = self.presentingViewController {
      let reflection = Mirror(reflecting: unknown)
      print("I am of type: \(reflection.subjectType)")
    }
    else {
      print("I am of type: \(type(of:self.presentingViewController))")
    }
    
    let isPresentingFromAddButton = self.presentingViewController is UINavigationController
    if isPresentingFromAddButton {
      self.dismiss(animated: true, completion: nil)
    }
    else {
      print(type(of: self.presentingViewController))
      _ = self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func rightScreenEdgeSwipedIn(_ sender: UIScreenEdgePanGestureRecognizer) {
    if sender.state == .ended {
      self.performSegue(withIdentifier: "showSegueToMarkdownNotesViewController", sender: self)
    }
  }
  
  @IBAction func unwindToNotesViewController(sender: UIStoryboardSegue) {}
  
  // MARK: - UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.textView.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let validBarButtonItem = sender as? UIBarButtonItem, validBarButtonItem === self.saveButton {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry)
    }
  }
}
