//
//  NotesTableViewController.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 8/4/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//


import UIKit

class NotesTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
//    var notes = [Note]()
    
    var noteDocuments = [NoteDocument]() {
        didSet {
            self.refreshNoteCount()
//            self.tableView.reloadData()
        }
    }
    var metadataQuery = NSMetadataQuery()
    
    var indexPath: IndexPath?
    var tableViewRefreshControl: UIRefreshControl!
    
    let deleteOrNotDeleteAlertView: FCAlertView = {
        let alertView = FCAlertView(type: .warning)
        alertView.dismissOnOutsideTouch = true
        alertView.hideDoneButton = true
        return alertView
    }()
    
    let iCloudConfigurationNotDetected: FCAlertView = {
        let alertView = FCAlertView(type: .warning)
        return alertView
    }()
    
    // MARK: - IBAction Methods
    
    @IBAction func unwindToNotesTableViewController(sender: UIStoryboardSegue) {
        guard let validNotesViewController = sender.source as? NotesViewController, let validNote = validNotesViewController.note else { return }
        let newIndexPath = IndexPath(row: 0, section: 0)
//        if self.presentedViewController is UINavigationController {
//            let newIndexPath = IndexPath(row: 0, section: 0)
//            self.notes.insert(validNote, at: 0)
//            self.tableView.insertRows(at: [newIndexPath], with: .top)
//        }
//        else {
//            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow, self.notes[selectedIndexPath.row].entry != validNote.entry else { return }
//            self.notes.remove(at: selectedIndexPath.row)
//            self.notes.insert(validNote, at: 0)
//            self.tableView.reloadData()
//        }
//        self.saveNotes()
        if self.presentedViewController is UINavigationController {
            self.delayExecutionBySecond(1, for: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.save(validNote, at: newIndexPath)
            })
        }
        else {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow, self.noteDocuments[selectedIndexPath.row].note.entry != validNote.entry else { return }
            self.delayExecutionBySecond(1, for: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.deleteNote(at: selectedIndexPath)
                weakSelf.save(validNote, at: newIndexPath)
            })
        }
    }
    
    // MARK: - Helper Methods
    
//    func loadSampleNotes() {
//        guard let firstNote = Note(entry: "Hello Sunshine! Come & tap me first!\n👇👇👇\n\nYou can power up your note by writing your words like **this** or _this_, create an [url link](http://apple.com), or even make a todo list:\n\n* Watch WWDC videos.\n* Write `code`.\n* Fetch my girlfriend for a ride.\n* Refactor `code`.\n\nOr even create quote:\n\n> A block of quote.\n\nTap *Go!* to preview your enhanced note.\n\nTap *How?* to learn more.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
//        guard let secondNote = Note(entry: "Swipe me left or tap edit to delete.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
//        guard let thirdNote = Note(entry: "Tap edit to move me or delete me.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
//        self.notes += [firstNote, secondNote, thirdNote]
//    }
    
    fileprivate func compareNoteDocumentModificationDateBetween(_ lhs: NoteDocument, and rhs: NoteDocument) -> Bool {
        guard let validLhsDate = lhs.fileModificationDate, let validRhsDate = rhs.fileModificationDate else { return false }
        return validLhsDate > validRhsDate
    }
    
    fileprivate func deleteNote(at indexPath: IndexPath) {
        let noteDocument = self.noteDocuments[indexPath.row]

        // TODO: - Investigate why enclosing using NSFileCoordinator will hang the app
//        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
//        fileCoordinator.coordinate(writingItemAt: noteDocument.fileURL,
//                                   options: NSFileCoordinator.WritingOptions.forDeleting,
//                                   error: nil) { [weak self] (_) in
//                                    guard let weakSelf = self else { return }
//                                    do {
//                                        try FileManager.default.removeItem(at: noteDocument.fileURL)
//                                        weakSelf.noteDocuments.remove(at: indexPath.row)
//                                        weakSelf.tableView.deleteRows(at: [indexPath], with: .bottom)
//                                        weakSelf.tableView.reloadData()
//                                        print("delete ok")
//                                    }
//                                    catch let error as NSError {
//                                        print("Error occured deleting a document. Reason: \(error.localizedDescription)")
//                                    }
//        }

        do {
            try FileManager.default.removeItem(at: noteDocument.fileURL)
        }
        catch let error as NSError {
            print("Error occurred deleting a document. Reason: \(error.localizedDescription)")
        }
        self.noteDocuments.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .bottom)
        self.tableView.reloadData()
    }
    
    fileprivate func delayExecutionBySecond(_ delay: Int, for anonFunc: @escaping () -> Void) {
        let when = DispatchTime.now() + .seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: when, execute: anonFunc)
    }
    
    fileprivate func displayShareSheet(from indexPath: IndexPath) {
//        let activityViewController = UIActivityViewController(activityItems: [self.notes[indexPath.row].entry], applicationActivities: nil)
//        self.present(activityViewController, animated: true) {
//            self.setEditing(false, animated: true)
//        }
        let activityViewController = UIActivityViewController(activityItems: [self.noteDocuments[indexPath.row].note.entry], applicationActivities: nil)
        self.present(activityViewController, animated: true) {
            self.setEditing(false, animated: true)
        }
    }
    
    fileprivate func loadDefaultNotes() {
        guard let firstNote = Note(entry: "Tap me to learn about my superpower!\n👇👇👇\n\nYou can power up your note by writing your words like **this** or _this_, create an [url link](http://apple.com), or even make a todo list:\n\n* Watch WWDC videos.\n* Write `code`.\n* Fetch my girlfriend for a ride.\n* Refactor `code`.\n\nOr even create quote:\n\n> A block of quote.\n\nTap *Go!* to preview your enhanced note.\n\nTap *How?* to learn more.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
        guard let secondNote = Note(entry: "Tap +, above right, to add a new note", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
        guard let thirdNote = Note(entry: "Tap Edit, above left, to move me or delete me.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
        guard let fourthNote = Note(entry: "Swipe me to the left for more options.", dateOfCreation: CurrentDateAndTimeHelper.get()) else { return }
        for (index, note) in [firstNote, secondNote, thirdNote, fourthNote].enumerated() {
            self.save(note, at: IndexPath(row: index, section: 0))
        }
    }
    
    fileprivate func loadNotes() {
        guard let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            self.iCloudConfigurationNotDetected.showAlert(inView: self,
                                                          withTitle: "Unable to Access iCloud Account",
                                                          withSubtitle: "Open Settings, iCloud, & sign in with your Apple ID.",
                                                          withCustomImage: nil,
                                                          withDoneButtonTitle: nil,
                                                          andButtons: nil)
            return
        }
        
        self.metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        self.metadataQuery.predicate = NSPredicate(format: "%K like '*'", NSMetadataItemFSNameKey)
        
        let sortDescriptorByRecentDateModified = NSSortDescriptor(key: NSMetadataItemFSContentChangeDateKey, ascending: false)
        self.metadataQuery.sortDescriptors = [sortDescriptorByRecentDateModified]
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotesTableViewController.processMetadataQueryDidFinishGathering(_:)),
                                               name: .NSMetadataQueryDidFinishGathering,
                                               object: self.metadataQuery)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotesTableViewController.processMetadataQueryDidUpdate(_:)),
                                               name: .NSMetadataQueryDidUpdate,
                                               object: self.metadataQuery)
        
        DispatchQueue.main.async {
            self.metadataQuery.enableUpdates()
            self.metadataQuery.start()
        }
    }
    
    func processMetadataQueryDidFinishGathering(_ notification: Notification) {
        print("metadataQueryDidFinishGathering called")
        
        let metadataQuery: NSMetadataQuery = notification.object as! NSMetadataQuery
        metadataQuery.disableUpdates()
        metadataQuery.stop()
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .NSMetadataQueryDidFinishGathering,
                                                  object: metadataQuery)
        NotificationCenter.default.removeObserver(self,
                                                  name: .NSMetadataQueryDidUpdate,
                                                  object: metadataQuery)
        
        self.noteDocuments.removeAll()
        
        if metadataQuery.resultCount > 0 {
            for metaDataItem in metadataQuery.results as! [NSMetadataItem] {
                let documentURL = metaDataItem.value(forAttribute: NSMetadataItemURLKey) as! URL
                let noteDocument = NoteDocument(fileURL: documentURL)
                noteDocument.open(completionHandler: { [weak self] (isSuccess: Bool) in
                    guard let weakSelf = self else { return }
                    if isSuccess {
                        // TODO: - Remove when done
                        /*
                        print("Loading notes from iCloud succeeded.")
                        print("-----")
                        print("fileName: \(noteDocument.localizedName)")
                        print("fileType: \(noteDocument.fileType!)")
                        print("dateModified: \(noteDocument.fileModificationDate!)")
                        print("documentState: \(noteDocument.documentState)")
                        print("-----")
                        */
                        weakSelf.noteDocuments.append(noteDocument)
                        if weakSelf.noteDocuments.count == metadataQuery.resultCount {
                            weakSelf.noteDocuments = weakSelf.noteDocuments.sorted(by: weakSelf.compareNoteDocumentModificationDateBetween)
                        }
                        weakSelf.tableView.reloadData()
                    }
                    else {
                        print("Loading notes from iCloud failed.")
                    }
                })
            }
        }
        else { self.loadDefaultNotes() }
        metadataQuery.enableUpdates()
    }
    
    func processMetadataQueryDidUpdate(_ notification: Notification) {
        print("processMetadataQueryDidUpdate called")
        
        let metadataQuery: NSMetadataQuery = notification.object as! NSMetadataQuery
        metadataQuery.disableUpdates()
        
        self.noteDocuments.removeAll()
        
        if metadataQuery.resultCount > 0 {
            for metaDataItem in metadataQuery.results as! [NSMetadataItem] {
                let documentURL = metaDataItem.value(forAttribute: NSMetadataItemURLKey) as! URL
                let noteDocument = NoteDocument(fileURL: documentURL)
                noteDocument.open(completionHandler: { [weak self] (isSuccess: Bool) in
                    guard let weakSelf = self else { return }
                    if isSuccess {
                        // TODO: - Remove when done
                        /*
                        print("Loading from iCloud succeeded.")
                        print("-----")
                        print("fileName: \(noteDocument.localizedName)")
                        print("fileType: \(noteDocument.fileType!)")
                        print("dateModified: \(noteDocument.fileModificationDate!)")
                        print("documentState: \(noteDocument.documentState)")
                        print("-----")
                        */
                        weakSelf.noteDocuments.append(noteDocument)
                        if weakSelf.noteDocuments.count == metadataQuery.resultCount {
                            weakSelf.noteDocuments = weakSelf.noteDocuments.sorted(by: weakSelf.compareNoteDocumentModificationDateBetween)
                        }
                        weakSelf.tableView.reloadData()
                    }
                    else {
                        print("Loading from iCloud failed.")
                    }
                })
            }
        }
        else { self.loadDefaultNotes() }
        metadataQuery.enableUpdates()
    }
    
    func refreshNoteListing() {
        self.loadNotes()
        self.tableViewRefreshControl.endRefreshing()
    }
    
    fileprivate func refreshNoteCount() {
        let noteCount = self.noteDocuments.count
        self.navigationItem.title = noteCount > 1 ? "\(noteCount) Notes" : "\(noteCount) Note"
    }
    
    fileprivate func save(_ note: Note, at indexPath: IndexPath) {
        guard let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            self.iCloudConfigurationNotDetected.showAlert(inView: self,
                                                          withTitle: "Unable to Access iCloud Account",
                                                          withSubtitle: "Open Settings, iCloud, & sign in with your Apple ID.",
                                                          withCustomImage: nil,
                                                          withDoneButtonTitle: nil,
                                                          andButtons: nil)
            return
        }
        let documentsDirectoryURL = iCloudContainerURL.appendingPathComponent("Documents")
        let noteURL = documentsDirectoryURL.appendingPathComponent("\(note.entry.components(separatedBy: NSCharacterSet.whitespaces).first!)-\(Date.timeIntervalSinceReferenceDate).txt")
        let noteDocument = NoteDocument(fileURL: noteURL)
        noteDocument.note = note
//        self.noteDocuments.insert(noteDocument, at: indexPath.row)
//        self.tableView.insertRows(at: [indexPath], with: .top)
//        self.tableView.reloadData()
        noteDocument.save(to: noteURL, for: .forCreating) { [weak self] (isSuccessfulSaved: Bool) in
            guard let weakSelf = self else { return }
            if isSuccessfulSaved {
                weakSelf.noteDocuments.insert(noteDocument, at: indexPath.row)
                weakSelf.tableView.insertRows(at: [indexPath], with: .top)
                print("Saving to iCloud & updating notes in table view succeeded.")
            }
            else {
                print("Saving to iCloud & updating notes in table view failed.")
            }
        }
    }

    // MARK: - NSCoding Methods
    
//    func saveNotes() {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.notes, toFile: Note.archiveURL.path)
//        if !isSuccessfulSave { print("unable to save note...") }
//    }
    
//    func loadNotes() -> [Note]? {
//        return NSKeyedUnarchiver.unarchiveObject(withFile: Notes.archiveURL.path) as? [Notes]
//    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let loadedNotes = self.loadNotes() {
//            self.notes = loadedNotes
//        }
//        else {
//            self.loadSampleNotes()
//        }

        self.loadNotes()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hexString: "#72889E")!]
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.tableView.separatorColor = UIColor(red: 114/255, green: 136/255, blue: 158/255, alpha: 0.075)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        self.deleteOrNotDeleteAlertView.delegate = self
        
        self.tableViewRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = UIColor(hexString: "#488AC6")
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh notes", attributes: [NSForegroundColorAttributeName: UIColor(hexString: "#488AC6")!])
            refreshControl.addTarget(self, action: #selector(NotesTableViewController.refreshNoteListing), for: .valueChanged)
            return refreshControl
        }()
        self.tableView.addSubview(self.tableViewRefreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadNotes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let validSegueIdentifier = segue.identifier, let validSegueIdentifierCase = NotesTableViewControllerSegue(rawValue: validSegueIdentifier) else {
            assertionFailure("Could not map segue identifier: \(String(describing: segue.identifier))")
            return
        }
        
        switch validSegueIdentifierCase {
        case .segueToNotesViewControllerFromCell:
            guard let validNotesViewController = segue.destination as? NotesViewController,
                let selectedNoteCell = sender as? NotesTableViewCell,
                let selectedIndexPath = self.tableView.indexPath(for: selectedNoteCell) else { return }
//            let selectedNote = self.notes[selectedIndexPath.row]
            let selectedNote = self.noteDocuments[selectedIndexPath.row].note
            validNotesViewController.note = selectedNote
        case .segueToNotesViewControllerFromAddButton:
            print("adding new note")
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.notes.count
        return self.noteDocuments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
//        
//        let note = self.notes[indexPath.row]
//        
//        cell.noteLabel.text = note.entry
//        cell.noteModificationTimeStampLabel.text = note.dateModificationTimeStamp
//        
//        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        let noteDocument = self.noteDocuments[indexPath.row]
        
        cell.noteLabel.text = noteDocument.note.entry
        cell.noteModificationTimeStampLabel.text = noteDocument.note.dateModificationTimeStamp
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let noteTobeMoved = self.notes[sourceIndexPath.row]
//        self.notes.remove(at: sourceIndexPath.row)
//        self.notes.insert(noteTobeMoved, at: destinationIndexPath.row)
        
        guard let noteToBeMoved = self.noteDocuments[sourceIndexPath.row].note else { return }
        self.deleteNote(at: sourceIndexPath)
        self.save(noteToBeMoved, at: destinationIndexPath)
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let shareButton: UITableViewRowAction = {
            let tableViewRowAction = UITableViewRowAction(style: .normal, title: "Share", handler: { [weak self] (_, indexPath) in
                guard let weakSelf = self else { return }
                weakSelf.displayShareSheet(from: indexPath)
            })
            tableViewRowAction.backgroundColor = UIColor(hexString: "#488AC6")
            return tableViewRowAction
        }()
        
        let deleteButton: UITableViewRowAction = {
            let tableViewRowAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] (_, indexPath) in
                guard let weakSelf = self else { return }
                weakSelf.indexPath = indexPath
                weakSelf.deleteOrNotDeleteAlertView.showAlert(inView: weakSelf,
                                                          withTitle: "Delete For Sure?",
                                                          withSubtitle: "There is no way to recover it.",
                                                          withCustomImage: nil,
                                                          withDoneButtonTitle: nil,
                                                          andButtons: [Delete.no.operation, Delete.yes.operation])
            })
            return tableViewRowAction
        }()
        
        return [shareButton, deleteButton]
    }
}

// MARK: - FCAlertViewDelegate Protocol

extension NotesTableViewController: FCAlertViewDelegate {
    func alertView(_ alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        guard let validIndexPath = self.indexPath else { return }
        if title == Delete.yes.operation {
//            self.notes.remove(at: validIndexPath.row)
//            tableView.deleteRows(at: [validIndexPath], with: .fade)
            self.deleteNote(at: validIndexPath)
        }
        else if title == Delete.no.operation {
            self.setEditing(false, animated: true)
        }
    }
}

// MARK: - NotesTableViewController Extension

extension NotesTableViewController {
    enum NotesTableViewControllerSegue: String {
        case segueToNotesViewControllerFromCell
        case segueToNotesViewControllerFromAddButton
    }
    
    enum Delete {
        case yes, no
        
        var operation: String {
            switch self {
            case .yes: return "Delete"
            case .no: return "Don't Delete"
            }
        }
    }
}
