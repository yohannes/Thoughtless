//
//  NotesViewController.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 8/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SafariServices
import SwiftHEXColors

class NotesViewController: UIViewController {
    
    // MARK: - Stored Properties
    
    var note: Note?
    
    var doesTextViewNeedToBeSaved: Bool!
    
    var lastOffsetY: CGFloat = 0
    
    let saveOrNotSaveAlertView: FCAlertView = {
        let alertView = FCAlertView(type: .caution)
        alertView.dismissOnOutsideTouch = true
        alertView.hideDoneButton = true
        return alertView
    }()
    
    let emptyNoteDeterrentAlertview: FCAlertView = {
        let alertView = FCAlertView(type: .warning)
        alertView.dismissOnOutsideTouch = true
        alertView.hideDoneButton = true
        return alertView
    }()
    
    enum Cursor: String {
        case left, right
        
        var direction: Int {
            if case .left = self { return -1 }
            else { return 1 }
        }
    }
    
    enum MarkdownSymbols: String {
        case moveLeft, hash, asterisk, underscore, greaterThan, dash, grave, done, moveRight
        
        var character: String {
            switch self {
            case .moveLeft: return "⬅️️"
            case .hash: return "#"
            case .asterisk: return "*"
            case .underscore: return "_"
            case .greaterThan: return ">"
            case .dash: return "-"
            case .grave: return "`"
            case .done: return "⌨"
            case .moveRight: return "➡️️"
            }
        }
        
        static let items = [ moveLeft, hash, asterisk, underscore, greaterThan, dash, grave, done, moveRight]
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
    
    @IBOutlet weak var powerUpYourNoteLabel: UILabel!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var bottomLayoutGuideTopToTextViewBottom: NSLayoutConstraint!
    
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
        
        if self.doesTextViewNeedToBeSaved == true {
            self.saveOrNotSaveAlertView.showAlert(inView: self,
                                                  withTitle: "Unsaved Change Detected",
                                                  withSubtitle: "Do you want to save or not save?",
                                                  withCustomImage: nil,
                                                  withDoneButtonTitle: nil,
                                                  andButtons: ["Don't Save", "Save"])
        }
        else {
            let isPresentingFromAddButton = self.presentingViewController is UINavigationController
            if isPresentingFromAddButton {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                //      print("d) I am of type: \(type(of: self.presentingViewController))")
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func markdownUserGuideButtonDidTouch(_ sender: UIButton) {
        guard let validURL = URL(string: "http://commonmark.org/help/") else { return }
        let safariViewController = SFSafariViewController(url: validURL)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction func previewMarkdownButtonDidTouch(_ sender: UIButton) {
        guard self.note != nil else { return }
        self.performSegue(withIdentifier: NotesViewControllerSegue.showSegueToMarkdownNotesViewController.rawValue, sender: self)
    }
    
    @IBAction func swipeLeftFromRightScreenEdgeGestureToShowMarkdown(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard self.note != nil else { return }
        if sender.state == .ended {
            self.performSegue(withIdentifier: NotesViewControllerSegue.showSegueToMarkdownNotesViewController.rawValue, sender: self)
        }
    }
    
    @IBAction func swipeRightFromLeftScreenEdgeGestureToCancelOrSave(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.textView.endEditing(true)
        
        self.saveOrNotSaveAlertView.showAlert(inView: self,
                                              withTitle: "Pardon the Interruption",
                                              withSubtitle: "Do you want to save or not save?",
                                              withCustomImage: nil,
                                              withDoneButtonTitle: nil,
                                              andButtons: ["Don't Save", "Save"])
    }
    
    @IBAction func swipeDownGestureToDismissKeyboard(_ sender: UISwipeGestureRecognizer) {
        self.textView.resignFirstResponder()
    }
    
    // MARK: - UIViewController Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let validBarButtonItem = sender as? UIBarButtonItem, validBarButtonItem === self.saveButton {
            let entry = self.textView.text ?? ""
            self.note = Note(entry: entry, dateOfCreation: CurrentDateAndTimeHelper.get())
        }
        else if segue.identifier == NotesViewControllerSegue.showSegueToMarkdownNotesViewController.rawValue {
            guard let validMarkdownNotesViewController = segue.destination as? MarkdownNotesViewController, let validNote = self.note else { return }
            validMarkdownNotesViewController.note = validNote
        }
        else if segue.identifier == NotesViewControllerSegue.unwindToNotesTableViewControllerFromNotesViewController.rawValue {
            let entry = self.textView.text ?? ""
            self.note = Note(entry: entry, dateOfCreation: CurrentDateAndTimeHelper.get())
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard !textView.text.isEmpty else {
            self.textView.endEditing(true)
            self.emptyNoteDeterrentAlertview.showAlert(inView: self,
                                                       withTitle: "Empty Note Detected",
                                                       withSubtitle: "You aren't allowed to save an empty note.",
                                                       withCustomImage: nil,
                                                       withDoneButtonTitle: nil,
                                                       andButtons: ["Understood"])
            return false
        }
        
        if identifier == NotesViewControllerSegue.unwindToNotesTableViewControllerFromNotesViewController.rawValue {
            self.performSegue(withIdentifier: identifier, sender: self)
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorThemeHelper.forBackground()
        
        self.setupKeyboardToolBarWithBarButtonItems()
        
        self.saveOrNotSaveAlertView.delegate = self
        self.emptyNoteDeterrentAlertview.delegate = self
        
        self.textView.delegate = self
        self.textView.textColor = ColorThemeHelper.forFont()
        self.textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        self.powerUpYourNoteLabel.textColor = ColorThemeHelper.forFont()
        
        self.doesTextViewNeedToBeSaved = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ColorThemeHelper.forFont()]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.setContentOffset(CGPoint(x:0, y: -64), animated: false)
        
        self.updateWordsCount()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Local Methods
    
    func barButtonItemOnToolBarDidTouch(sender: UIBarButtonItem) {
        guard let validButtonTitle = sender.title else { return }
        if case "➡️️" = validButtonTitle { self.moveCursor(.right) }
        else if case "⬅️️" = validButtonTitle { self.moveCursor(.left) }
        else if case "⌨" = validButtonTitle { self.textView.endEditing(true) }
        else { self.textView.insertText(validButtonTitle) }
    }
    
    fileprivate func moveCursor(_ cursor: Cursor) {
        guard let selectedTextRange = self.textView.selectedTextRange, let newCursorPosition = textView.position(from: selectedTextRange.start, offset: cursor.direction) else { return }
        textView.selectedTextRange = textView.textRange(from: newCursorPosition, to: newCursorPosition)
    }
    
    fileprivate func setupKeyboardToolBarWithBarButtonItems() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        toolBar.tintColor = UIColor.black
        
        var barButtonItems = [UIBarButtonItem]()
        for (index, value) in MarkdownSymbols.items.enumerated() {
            let barButtonItem = self.setupBarButtonItemOnKeyboardToolbarWith(title: value.character)
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
    
    fileprivate func updateWordsCount() {
        let trimmedString = self.textView.text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        if trimmedString.count == 1 {
            self.navigationItem.title = trimmedString.first!.characters.count > 1 ? "Word Count: \(trimmedString.count)" : ""
        }
        else {
            self.navigationItem.title = "Word Count: \(trimmedString.count)"
        }
    }
}

// MARK: - FCAlertViewDelegate Protocol

extension NotesViewController: FCAlertViewDelegate {
    
    func alertView(_ alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        if title == "Save" {
            self.textView.endEditing(true)
            let _ = self.shouldPerformSegue(withIdentifier: NotesViewControllerSegue.unwindToNotesTableViewControllerFromNotesViewController.rawValue, sender: self)
        }
        else if title == "Don't Save" {
            self.doesTextViewNeedToBeSaved = false
            self.cancelButtonDidTouch(sender: self.cancelButton)
        }
        else if title == "Understood" {
            self.textView.becomeFirstResponder()
        }
    }
}

// MARK: - NotesViewController Extension

extension NotesViewController {
    enum NotesViewControllerSegue: String {
        case showSegueToMarkdownNotesViewController
        case unwindToNotesTableViewControllerFromNotesViewController
    }
}

// MARK: - UIScrollViewDelegate Protocol

extension NotesViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > self.lastOffsetY {
            self.toolbar.isHidden = true
            self.powerUpYourNoteLabel.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            
            self.bottomLayoutGuideTopToTextViewBottom.constant = 0
        }
        else {
            self.toolbar.isHidden = false
            self.powerUpYourNoteLabel.isHidden = false
            self.navigationController?.navigationBar.isHidden = false
            
            self.bottomLayoutGuideTopToTextViewBottom.constant = 44
        }
    }
}

// MARK: - UITextViewDelegate Protocol

extension NotesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.doesTextViewNeedToBeSaved = true
        
        self.updateWordsCount()
    }
}
