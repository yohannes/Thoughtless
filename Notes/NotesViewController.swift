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
    case hash = "#", asterisk = "*", underscore = "_", greaterThan = ">", dash = "-", grave = "`"
    static let count = [hash, asterisk, greaterThan, dash, grave]
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
    print("a) I am of type: \(self.presentingViewController.self)")
    
    // Check the type of an object #2. More: http://stackoverflow.com/a/33001534/2229062
    if let unknown: AnyObject = self.presentingViewController {
      let reflection = Mirror(reflecting: unknown)
      print("b) I am of type: \(reflection.subjectType)")
    }
    else {
      print("c) I am of type: \(type(of:self.presentingViewController))")
    }
    
    let isPresentingFromAddButton = self.presentingViewController is UINavigationController
    if isPresentingFromAddButton {
      self.dismiss(animated: true, completion: nil)
    }
    else {
      print("d) I am of type: \(type(of: self.presentingViewController))")
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
      let _ = self.shouldPerformSegue(withIdentifier: "unwindToNotesTableViewConroller", sender: self)
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
  
  @IBAction func unwindToNotesViewController(_ sender: UIStoryboardSegue) {}
  
  // MARK: - UIViewController Methods
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let validBarButtonItem = sender as? UIBarButtonItem, validBarButtonItem === self.saveButton {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry)
    }
    else if segue.identifier == "showSegueToMarkdownNotesViewController" {
      guard let validMarkdownNotesViewController = segue.destination as? MarkdownNotesViewController, let validNote = self.note else { return }
      validMarkdownNotesViewController.note = validNote
    }
    else if segue.identifier == "unwindToNotesTableViewController" {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry)
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
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupKeyboardToolBarWithBarButtonItems()
  }
  
  // MARK: - Helper Methods
  
  func barButtonItemOnToolBarDidTouch(sender: UIBarButtonItem) {
    guard let validButtonTitle = sender.title else { return }
    if sender.title == "Done" {
      self.textView.endEditing(true)
    }
    else {
      self.textView.insertText(validButtonTitle)
    }
  }
  
  fileprivate func setupKeyboardToolBarWithBarButtonItems() {
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
    toolBar.isTranslucent = false
    //    toolBar.tintColor = UIColor(red: 0, green: 118, blue: 255, alpha: 1)
    toolBar.barTintColor = UIColor(red: 249, green: 249, blue: 249, alpha: 1)
    toolBar.tintColor = UIColor.black
    
    // TODO: - see if you can for loop all these repeated button item initializations
//    let barButtonItems: [UIBarButtonItem]
//    for _ in MarkdownSymbols.count {
//      barButtonItems += UIBarButtonItem
//    }
    ///case hash = "#", asterisk = "*", underscore = "_" greaterThan = ">", dash = "-", grave = "`"
    
    let hashBarButtonItem = UIBarButtonItem(title: MarkdownSymbols.hash.rawValue, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let asteriskBarButtonItem = UIBarButtonItem(title: MarkdownSymbols.asterisk.rawValue, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let underscoreBarButtonItem = UIBarButtonItem(title: MarkdownSymbols.underscore.rawValue, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let greaterThanSignBarButtonItem = UIBarButtonItem(title: MarkdownSymbols.greaterThan.rawValue, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let dashBarButtonItem = UIBarButtonItem(title: MarkdownSymbols.dash.rawValue, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let graveBarButtonItem = UIBarButtonItem(title: MarkdownSymbols.grave.rawValue, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    let barButtonFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.items = [hashBarButtonItem,
                     barButtonFlexibleSpace,
                     asteriskBarButtonItem,
                     barButtonFlexibleSpace,
                     underscoreBarButtonItem,
                     barButtonFlexibleSpace,
                     greaterThanSignBarButtonItem,
                     barButtonFlexibleSpace,
                     dashBarButtonItem,
                     barButtonFlexibleSpace,
                     graveBarButtonItem,
                     barButtonFlexibleSpace,
                     doneBarButtonItem]
    self.textView.inputAccessoryView = toolBar
  }
}
