
/*
 * NotesViewController.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 8/18/16.
 * Copyright © 2017 Yohannes Wijaya. All respective rights reserved.
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
import SafariServices
import SwiftHEXColors
import HidingNavigationBar
import CFAlertViewController

class NotesViewController: UIViewController {
    
    // MARK: - Stored Properties
    
    var note: Note?
    
    var doesTextViewNeedToBeSaved: Bool!
    
    var hidingNavigationBarManager: HidingNavigationBarManager?
    
    let dismissModallyIconName = "icons8-Cancel-22"
    let popViewControllerIconName = "icons8-Return-22"
    
    enum Cursor: String {
        case left, right
        
        var direction: Int {
            if case .left = self { return -1 }
            else { return 1 }
        }
    }
    
    enum MarkdownSymbols: String {
        case moveLeft, hash, asterisk, underscore, greaterThan, dash, leftBracket, rightBracket, grave, strikeThrough, done, moveRight
        
        var character: String {
            switch self {
            case .moveLeft: return "⬅️️"
            case .hash: return "#"
            case .asterisk: return "*"
            case .underscore: return "_"
            case .greaterThan: return ">"
            case .dash: return "-"
            case .leftBracket: return "["
            case .rightBracket: return "]"
            case .grave: return "`"
            case .strikeThrough: return "~"
            case .done: return "🔽"
            case .moveRight: return "➡️️"
            }
        }
        
        static let items = [moveLeft, hash, asterisk, underscore, greaterThan, dash, leftBracket, rightBracket, grave, strikeThrough, done, moveRight]
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
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var previewBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: - IBAction Methods
    
    @IBAction func cancelBarButtonItemDidTouch(_ sender: UIBarButtonItem) {
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
            self.presentShouldSaveAlertController()
        }
        else {
            let isPresentingFromAddButton = self.presentingViewController is UINavigationController
            if isPresentingFromAddButton {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func markdownUserGuideButtonDidTouch(_ sender: UIBarButtonItem) {
        guard let validURL = URL(string: "http://commonmark.org/help/") else { return }
        let noteSafariViewController = NoteSafariViewController(url: validURL)
        noteSafariViewController.modalPresentationStyle = .overFullScreen
        self.present(noteSafariViewController, animated: true) {
            let screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleScreenEdgePanGesture))
            screenEdgePanGestureRecognizer.edges = .left
            noteSafariViewController.edgeView?.addGestureRecognizer(screenEdgePanGestureRecognizer)
        }
    }
    
    @IBAction func previewMarkdownButtonDidTouch(_ sender: UIBarButtonItem) {
        guard self.note != nil else { return }
        self.performSegue(withIdentifier: NotesViewControllerSegue.showSegueToMarkdownNotesWebViewController.rawValue, sender: self)
    }
    
    @IBAction func swipeLeftFromRightGestureToShowMarkdown(_ sender: UIGestureRecognizer) {
        guard self.note != nil && self.textView.isFirstResponder == false && self.previewBarButtonItem.isEnabled != false else { return }
        if sender.state == .ended {
            self.performSegue(withIdentifier: NotesViewControllerSegue.showSegueToMarkdownNotesWebViewController.rawValue, sender: self)
        }
    }
    
    @IBAction func swipeRightFromLeftGestureToCancelOrSave(_ sender: UIGestureRecognizer) {
        self.textView.endEditing(true)
        if self.doesTextViewNeedToBeSaved == true {
            if self.presentedViewController == nil {
                self.presentShouldSaveAlertController()
            }
        }
        else {
            self.doesTextViewNeedToBeSaved = false
            self.cancelBarButtonItemDidTouch(self.cancelBarButtonItem)
        }
    }
    
    @IBAction func swipeDownGestureToDismissKeyboard(_ sender: UISwipeGestureRecognizer) {
        self.textView.resignFirstResponder()
    }
    
    // MARK: - UIViewController Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let validButtonItem = sender as? UIBarButtonItem, validButtonItem === self.saveBarButtonItem {
            let entry = self.textView.text ?? ""
            self.note = Note(entry: entry, dateOfCreation: self.getCurrentDateAndTime())
            self.textView.endEditing(true)
        }
        else if segue.identifier == NotesViewControllerSegue.showSegueToMarkdownNotesWebViewController.rawValue {
            guard let validMarkdownNotesWebViewController = segue.destination as? MarkdownNotesWebViewController, let validNote = self.note else { return }
            validMarkdownNotesWebViewController.note = validNote
        }
        else if segue.identifier == NotesViewControllerSegue.unwindToNotesTableViewControllerFromNotesViewController.rawValue {
            let entry = self.textView.text ?? ""
            self.note = Note(entry: entry, dateOfCreation: self.getCurrentDateAndTime())
            self.textView.endEditing(true)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard !textView.text.isEmpty else {
            self.textView.endEditing(true)

            let emptyNoteDeterrentAlertViewController = CFAlertViewController.alertController(title: NSLocalizedString("Write Something", comment: ""),
                                                                                              message: NSLocalizedString("You aren't allowed to save an empty note.", comment: ""),
                                                                                              textAlignment: .left,
                                                                                              preferredStyle: .alert,
                                                                                              didDismissAlertHandler: nil)
            let understoodAlertViewAction = CFAlertAction.action(title: "UNDERSTOOD",
                                                                 style: .Default,
                                                                 alignment: .right,
                                                                 backgroundColor: ColorThemeHelper.reederGray(),
                                                                 textColor: ColorThemeHelper.reederCream(),
                                                                 handler: { [weak self] (_) in
                                                                    guard let weakSelf = self else { return }
                                                                    weakSelf.textView.becomeFirstResponder()
            })
            emptyNoteDeterrentAlertViewController.shouldDismissOnBackgroundTap = false
            emptyNoteDeterrentAlertViewController.addAction(understoodAlertViewAction)
            self.present(emptyNoteDeterrentAlertViewController, animated: true, completion: nil)
            
            return false
        }
        
        if identifier == NotesViewControllerSegue.unwindToNotesTableViewControllerFromNotesViewController.rawValue {
            self.performSegue(withIdentifier: identifier, sender: self)
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.presentingViewController is UINavigationController {
            self.previewBarButtonItem.isEnabled = false
        }
        
        self.view.backgroundColor = ColorThemeHelper.reederGray()
        
        self.setupKeyboardToolBarWithBarButtonItems()
        
        self.textView.delegate = self
        self.textView.textColor = ColorThemeHelper.reederCream()
        self.textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        self.doesTextViewNeedToBeSaved = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ColorThemeHelper.reederCream()]
        self.navigationController?.isToolbarHidden = true
        
        self.navigationItem.hidesBackButton = true
        
        self.hidingNavigationBarManager = HidingNavigationBarManager(viewController: self, scrollView: self.textView)
        self.hidingNavigationBarManager?.manageBottomBar(self.toolbar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hidingNavigationBarManager?.viewWillAppear(animated)
        
        self.updateWordsCount()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.toggleCancelBarButtonItemIcon()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.hidingNavigationBarManager?.viewWillDisappear(animated)
    }
    
    // MARK: - Local Methods
    
    func barButtonItemOnToolBarDidTouch(sender: UIBarButtonItem) {
        guard let validButtonTitle = sender.title else { return }
        if case "➡️️" = validButtonTitle { self.moveCursor(.right) }
        else if case "⬅️️" = validButtonTitle { self.moveCursor(.left) }
        else if case "🔽" = validButtonTitle {
            self.hidingNavigationBarManager?.expand()
            self.textView.endEditing(true)
        }
        else { self.textView.insertText(validButtonTitle) }
    }
    
    func handleScreenEdgePanGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .changed {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func moveCursor(_ cursor: Cursor) {
        guard let selectedTextRange = self.textView.selectedTextRange, let newCursorPosition = textView.position(from: selectedTextRange.start, offset: cursor.direction) else { return }
        textView.selectedTextRange = textView.textRange(from: newCursorPosition, to: newCursorPosition)
    }
    
    fileprivate func presentShouldSaveAlertController() {
        let shouldSaveAlertViewController = CFAlertViewController.alertController(title: NSLocalizedString("There's Unsaved Change", comment: ""),
                                                                                  message: NSLocalizedString("Please choose your action carefully.", comment: ""),
                                                                                  textAlignment: .center,
                                                                                  preferredStyle: .actionSheet,
                                                                                  didDismissAlertHandler: nil)
        let dontSaveAlertViewAction = CFAlertAction.action(title: NSLocalizedString("DON'T SAVE", comment: ""),
                                                           style: .Destructive,
                                                           alignment: .justified,
                                                           backgroundColor: ColorThemeHelper.vividRed(),
                                                           textColor: ColorThemeHelper.reederCream()) { [weak self] (_) in
                                                            guard let weakSelf = self else { return }
                                                            weakSelf.doesTextViewNeedToBeSaved = false
                                                            weakSelf.cancelBarButtonItemDidTouch(weakSelf.cancelBarButtonItem)
        }
        let saveAlertViewAction = CFAlertAction.action(title: NSLocalizedString("SAVE", comment: ""),
                                                       style: .Default,
                                                       alignment: .justified,
                                                       backgroundColor: ColorThemeHelper.reederGray(),
                                                       textColor: ColorThemeHelper.reederCream()) { [weak self] (_) in
                                                        guard let weakSelf = self else { return }
                                                        weakSelf.textView.endEditing(true)
                                                        let _ = weakSelf.shouldPerformSegue(withIdentifier: NotesViewControllerSegue.unwindToNotesTableViewControllerFromNotesViewController.rawValue, sender: weakSelf)
        }
        let editAgainAlertViewAction = CFAlertAction.action(title: NSLocalizedString("EDIT AGAIN", comment: ""),
                                                       style: .Default,
                                                       alignment: .justified,
                                                       backgroundColor: ColorThemeHelper.reederMud(),
                                                       textColor: ColorThemeHelper.reederCream()) { [weak self] (_) in
                                                        guard let weakSelf = self else { return }
                                                        weakSelf.textView.becomeFirstResponder()
        }
        
        shouldSaveAlertViewController.shouldDismissOnBackgroundTap = false
        shouldSaveAlertViewController.addAction(dontSaveAlertViewAction)
        shouldSaveAlertViewController.addAction(saveAlertViewAction)
        shouldSaveAlertViewController.addAction(editAgainAlertViewAction)
        self.present(shouldSaveAlertViewController, animated: true, completion: nil)
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
    
    fileprivate func toggleCancelBarButtonItemIcon() {
        let dismissModallyBarButtonItemIconImage = UIImage(named: self.dismissModallyIconName)
        let popViewControllerBarButtonItemIconImage = UIImage(named: self.popViewControllerIconName)
        
        self.cancelBarButtonItem.image = self.presentingViewController is UINavigationController ? dismissModallyBarButtonItemIconImage : popViewControllerBarButtonItemIconImage
    }
    
    fileprivate func updateWordsCount() {
        let trimmedString = self.textView.text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        if trimmedString.count == 1 {
            self.navigationItem.title = trimmedString.first!.characters.count > 1 ? "Word Count: \(trimmedString.count)" : "What do you have in mind?"
        }
        else {
            self.navigationItem.title = "Word Count: \(trimmedString.count)"
        }
    }
}

// MARK: - NotesViewController Extension

extension NotesViewController {
    enum NotesViewControllerSegue: String {
        case showSegueToMarkdownNotesWebViewController
        case unwindToNotesTableViewControllerFromNotesViewController
    }
}

// MARK: - CurrentDateAndTimeHelper Protocol

extension NotesViewController: CurrentDateAndTimeHelper {}

// MARK: - UIScrollViewDelegate Protocol

extension NotesViewController: UIScrollViewDelegate {
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.hidingNavigationBarManager?.shouldScrollToTop()
        return true
    }
}

// MARK: - UITextViewDelegate Protocol

extension NotesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.doesTextViewNeedToBeSaved = true
        
        self.updateWordsCount()
        
        self.previewBarButtonItem.isEnabled = false
    }
}
