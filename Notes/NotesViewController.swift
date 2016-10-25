//
//  NotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SafariServices

class NotesViewController: UIViewController {
  
  // MARK: - Stored Properties
  
  var note: Notes?
  
  enum MarkdownSymbols: String {
    case hash = "#", asterisk = "*", underscore = "_", greaterThan = ">", dash = "-", grave = "`", done = "⌨"
    static let items = [hash, asterisk, underscore, greaterThan, dash, grave, done]
  }
  
  // MARK: - IBOutlet Properties
  
  @IBOutlet weak var textView: UITextView! {
    didSet {
      if let validNote = self.note {
        self.textView.text = validNote.entry
      }
      else {
        self.textView.sizeToFit()
        self.textView.becomeFirstResponder()
      }
    }
  }
  
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!

  // MARK: - IBAction Methods
  
  @IBAction func cancelButtonDidTouch(sender: UIBarButtonItem) {
    self.textView.resignFirstResponder()
    
    // Check the type of an object #1. More: http://stackoverflow.com/a/25345480/2229062
//    print("a) I am of type: \(self.presentingViewController.self)")
    
    // Check the type of an object #2. More: http://stackoverflow.com/a/33001534/2229062
//    if let unknown: AnyObject = self.presentingViewController {
//      let reflection = Mirror(reflecting: unknown)
//      print("b) I am of type: \(reflection.subjectType)")
//    }
//    else {
//      print("c) I am of type: \(type(of:self.presentingViewController))")
//    }
    
    let isPresentingFromAddButton = self.presentingViewController is UINavigationController
    if isPresentingFromAddButton {
      self.dismiss(animated: true, completion: nil)
    }
    else {
//      print("d) I am of type: \(type(of: self.presentingViewController))")
      _ = self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func markdownUserGuideButtonDidTouch(_ sender: UIButton) {
    guard let validURL = URL(string: "http://commonmark.org/help/") else { return }
    let safariViewController = SFSafariViewController(url: validURL)
    self.present(safariViewController, animated: true, completion: nil)
  }
  
  @IBAction func previewMarkdownButtonDidTouch(_ sender: UIButton) {
    guard self.note != nil else { return }
    self.performSegue(withIdentifier: "showSegueToMarkdownNotesViewController", sender: self)
  }
  
  @IBAction func swipeLeftFromRightScreenEdgeGestureToShowMarkdown(_ sender: UIScreenEdgePanGestureRecognizer) {
    guard self.note != nil else { return }
    if sender.state == .ended {
      self.performSegue(withIdentifier: "showSegueToMarkdownNotesViewController", sender: self)
    }
  }
  
  @IBAction func swipeRightFromLeftScreenEdgeGestureToCancelOrSave(_ sender: UIScreenEdgePanGestureRecognizer) {
    self.textView.endEditing(true)
    let alertController = UIAlertController(title: "Sorry For The Interruption", message: "Do you want to save or not save?", preferredStyle: .alert)
    let notSaveAlertAction = UIAlertAction(title: "Don't Save", style: .cancel) { (_) in
      self.cancelButtonDidTouch(sender: self.cancelButton)
    }
    let saveAlertAction = UIAlertAction(title: "Save", style: .default) { (_) in
      let _ = self.shouldPerformSegue(withIdentifier: "unwindToNotesTableViewControllerFromNotesViewController", sender: self)
    }
    alertController.addAction(notSaveAlertAction)
    alertController.addAction(saveAlertAction)
    if self.presentedViewController == nil {
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  @IBAction func swipeDownGestureToDismissKeyboard(_ sender: UISwipeGestureRecognizer) {
    self.textView.resignFirstResponder()
  }
  
  // MARK: - UIViewController Methods
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let validBarButtonItem = sender as? UIBarButtonItem, validBarButtonItem === self.saveButton {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry, dateOfCreation: CurrentDateAndTimeHelper.get())
    }
    else if segue.identifier == "showSegueToMarkdownNotesViewController" {
      guard let validMarkdownNotesViewController = segue.destination as? MarkdownNotesViewController, let validNote = self.note else { return }
      validMarkdownNotesViewController.note = validNote
    }
    else if segue.identifier == "unwindToNotesTableViewControllerFromNotesViewController" {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry, dateOfCreation: CurrentDateAndTimeHelper.get())
    }
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    guard !textView.text.isEmpty else {
      let alertController = UIAlertController(title: "Empty Note Detected", message: "You cannot save an empty note.", preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
        self.textView.becomeFirstResponder()
      }))
      self.present(alertController, animated: true, completion: nil)
      return false
    }
    if identifier == "unwindToNotesTableViewControllerFromNotesViewController" {
      self.performSegue(withIdentifier: identifier, sender: self)
      return true
    }
    else if identifier == "unwindToNotesTableViewControllerFromSaveBarButtonItem" {
      self.textView.endEditing(true)
      return true
    }
    else { return false }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupKeyboardToolBarWithBarButtonItems()
  }
  
  // MARK: - Local Methods
  
  func barButtonItemOnToolBarDidTouch(sender: UIBarButtonItem) {
    guard let validButtonTitle = sender.title else { return }
    if sender.title == "⌨" {
      self.textView.endEditing(true)
    }
    else {
      self.textView.insertText(validButtonTitle)
    }
  }
  
  fileprivate func setupKeyboardToolBarWithBarButtonItems() {
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
    toolBar.isTranslucent = false
    toolBar.barTintColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    toolBar.tintColor = UIColor.black
    
    var barButtonItems = [UIBarButtonItem]()
    for (index, value) in MarkdownSymbols.items.enumerated() {
      let barButtonItem = self.setupBarButtonItemOnKeyboardToolbarWith(title: value.rawValue)
      barButtonItems.append(barButtonItem)
      if index < MarkdownSymbols.items.count - 1 {
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
      }
    }
    
    toolBar.items = barButtonItems
    self.textView.inputAccessoryView = toolBar
  }
  
  fileprivate func setupBarButtonItemOnKeyboardToolbarWith(title: String) -> UIBarButtonItem {
    let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    return barButtonItem
  }
}
