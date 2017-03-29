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

    var noteDocuments = [NoteDocument]() {
        didSet {
            self.refreshNoteCount()
        }
    }
    var metadataQuery = NSMetadataQuery()
    
    var tableViewRefreshControl: UIRefreshControl!
    
    var ubiquityIdentityToken = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
    let iCloudEnabledKey = "iCloudEnabled"
    
    // MARK: - IBAction Methods
    
    @IBAction func unwindToNotesTableViewController(sender: UIStoryboardSegue) {
        guard let validNotesViewController = sender.source as? NotesViewController, let validNote = validNotesViewController.note else { return }
        let newIndexPath = IndexPath(row: 0, section: 0)
        if self.presentedViewController is UINavigationController {
            self.delayExecutionByMilliseconds(1000, for: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.save(validNote, at: newIndexPath)
            })
        }
        else {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow, self.noteDocuments[selectedIndexPath.row].note.entry != validNote.entry else { return }
            self.delayExecutionByMilliseconds(1000, for: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.deleteNote(at: selectedIndexPath)
                weakSelf.save(validNote, at: newIndexPath)
            })
        }
    }
    
    // MARK: - Helper Methods
    
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
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.reloadData()
    }
    
    fileprivate func delayExecutionByMilliseconds(_ delay: Int, for anonFunc: @escaping () -> Void) {
        let when = DispatchTime.now() + .milliseconds(delay)
        DispatchQueue.main.asyncAfter(deadline: when, execute: anonFunc)
    }
    
    fileprivate func displayShareSheet(from indexPath: IndexPath) {
        let activityViewController = UIActivityViewController(activityItems: [self.noteDocuments[indexPath.row].note.entry], applicationActivities: nil)
        self.present(activityViewController, animated: true) {
            self.setEditing(false, animated: true)
        }
    }
    
    func iCloudAccountAvailabilityHasChanged() {
        print("iCloud account availability has changed. [NotesTableViewController]")
        guard let archivediCloudTokenData = UserDefaults.standard.data(forKey: self.ubiquityIdentityToken), let archivediCloudTokenRaw = NSKeyedUnarchiver.unarchiveObject(with: archivediCloudTokenData) as? (NSCoding & NSCopying & NSObjectProtocol) else { return }
        if !archivediCloudTokenRaw.isEqual(FileManager.default.ubiquityIdentityToken) {
            // Update iCloud token & rescan docs.
            print("Different iCloud account detected.")
        }
    }
    
    fileprivate func loadDefaultNotes() {
        guard let firstNote = Note(entry: "Tap me to learn about my superpower!\n\nPower up your note by writing your words like **this**, *this*, or ~~this~~.\nCreate an [url link](http://apple.com).\nMake a todo list:\n\n* Send my girlfriend home.\n* Watch WWDC videos.\n* Write `code`.\n\n1. Refactor `code`.\n2. Build codebase.\n3. Chill while waiting for build to finish.\n\nCreate a block of quotes:\n\n> A block of quote.\n> Another block of quote.\n> Yet another block of quote.\n\nOr a bunch of codes too:\n\n```\nlet appTitle = 'Thoughtless'\nprint('This app is called \\(appTitle)')\n```\n\nTap *Preview* to see your enhanced note.\n\nTap *Markdown* to access tutorial.", dateOfCreation: self.getCurrentDateAndTime()) else { return }
        guard let secondNote = Note(entry: "Tap +, above right, to add a new note", dateOfCreation: self.getCurrentDateAndTime()) else { return }
        guard let thirdNote = Note(entry: "Tap Edit, above left, to move me or delete me.", dateOfCreation: self.getCurrentDateAndTime()) else { return }
        guard let fourthNote = Note(entry: "Swipe me to the left for more options.", dateOfCreation: self.getCurrentDateAndTime()) else { return }
        for (index, note) in [firstNote, secondNote, thirdNote, fourthNote].enumerated() {
            self.save(note, at: IndexPath(row: index, section: 0))
        }
    }
    
    func loadNotes() {
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
        else {
            self.delayExecutionByMilliseconds(1000, for: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.loadDefaultNotes()
            })
        }
        metadataQuery.enableUpdates()
    }
    
    func processMetadataQueryDidUpdate(_ notification: Notification) {
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
        else {
            self.delayExecutionByMilliseconds(1000, for: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.loadDefaultNotes()
            })
        }
        metadataQuery.enableUpdates()
    }
    
    func refreshNoteListing() {
        self.delayExecutionByMilliseconds(375) {
            self.loadNotes()
        }
        self.tableViewRefreshControl.endRefreshing()
    }
    
    fileprivate func refreshNoteCount() {
        let noteCount = self.noteDocuments.count
        if noteCount > 1 {
            self.navigationItem.title = "\(noteCount) Notes"
        }
        else if noteCount > 0 {
            self.navigationItem.title = "\(noteCount) Note"
        }
        else {
            self.navigationItem.title = ""
        }
    }
    
    fileprivate func save(_ note: Note, at indexPath: IndexPath) {
        guard let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else { return }
        let documentsDirectoryURL = iCloudContainerURL.appendingPathComponent("Documents")
        let noteURL = documentsDirectoryURL.appendingPathComponent("\(note.entry.components(separatedBy: NSCharacterSet.whitespaces).first!)-\(Date.timeIntervalSinceReferenceDate).txt")
        let noteDocument = NoteDocument(fileURL: noteURL)
        noteDocument.note = note
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
    
    func verifyiCloudAccount() {
        guard UserDefaults.standard.bool(forKey: self.iCloudEnabledKey) == true else { return }
        
        guard let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            let iCloudConfigurationAlertController = UIAlertController(title: NSLocalizedString("Misconfigured iCloud Account", comment: ""),
                                                                       message: NSLocalizedString("You have set Thoughtless to sync your notes via iCloud. Ensure you sign in to iCloud & iCloud Drive is turned on.", comment: ""),
                                                                       preferredStyle: .alert)
            let iCloudConfigurationAlertAction = UIAlertAction(title: NSLocalizedString("Verify iCloud Account", comment: ""),
                                                                style: .default,
                                                                handler: { (_) in
                                                                    guard let iCloudSettingURL = URL(string: "App-Prefs:root=CASTLE") else { return }
                                                                    UIApplication.shared.openURL(iCloudSettingURL)
            })
            iCloudConfigurationAlertController.addAction(iCloudConfigurationAlertAction)
            self.present(iCloudConfigurationAlertController, animated: true, completion: nil)
            return
        }
        self.loadNotes()
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ColorThemeHelper.reederCream()]
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.tableView.separatorColor = ColorThemeHelper.reederCream(alpha: 0.05)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        self.tableViewRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = ColorThemeHelper.reederCream()
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh notes", attributes: [NSForegroundColorAttributeName: ColorThemeHelper.reederCream()])
            refreshControl.addTarget(self, action: #selector(NotesTableViewController.refreshNoteListing), for: .valueChanged)
            return refreshControl
        }()
        self.tableView.addSubview(self.tableViewRefreshControl)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotesTableViewController.verifyiCloudAccount),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotesTableViewController.iCloudAccountAvailabilityHasChanged),
                                               name: NSNotification.Name.NSUbiquityIdentityDidChange,
                                               object: nil)
        self.verifyiCloudAccount()
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
        return self.noteDocuments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        let noteDocument = self.noteDocuments[indexPath.row]
        
        cell.noteLabel.text = noteDocument.note.entry
        cell.noteModificationTimeStampLabel.text = noteDocument.note.dateModificationTimeStamp
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let shareButton: UITableViewRowAction = {
            let tableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Share", comment: ""), handler: { [weak self] (_, indexPath) in
                guard let weakSelf = self else { return }
                weakSelf.displayShareSheet(from: indexPath)
            })
            tableViewRowAction.backgroundColor = ColorThemeHelper.reederCharcoal()
            return tableViewRowAction
        }()
        
        let deleteButton: UITableViewRowAction = {
            let tableViewRowAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: ""), handler: { [weak self] (_, indexPath) in
                guard let weakSelf = self else { return }
                
                let shouldDeleteAlertController = UIAlertController(title: NSLocalizedString("Delete For Sure?", comment: ""),
                                                                    message: NSLocalizedString("There is no way to recover it.", comment: ""),
                                                                    preferredStyle: .alert)
                let deleteAlertAction = UIAlertAction(title: Delete.yes.note, style: .destructive, handler: { (_) in
                    weakSelf.deleteNote(at: indexPath)
                })
                let dontDeleteAlertAction = UIAlertAction(title: Delete.no.note, style: .cancel, handler: { (_) in
                    weakSelf.setEditing(false, animated: true)
                })
                shouldDeleteAlertController.addAction(deleteAlertAction)
                shouldDeleteAlertController.addAction(dontDeleteAlertAction)
                weakSelf.present(shouldDeleteAlertController, animated: true, completion: nil)
                
            })
            tableViewRowAction.backgroundColor = ColorThemeHelper.reederMud()
            return tableViewRowAction
        }()
        
        return [deleteButton, shareButton]
    }
}

// MARK: - CurrentDateAndTimeHelper Protocol

extension NotesTableViewController: CurrentDateAndTimeHelper {}

// MARK: - NotesTableViewController Extension

extension NotesTableViewController {
    enum NotesTableViewControllerSegue: String {
        case segueToNotesViewControllerFromCell
        case segueToNotesViewControllerFromAddButton
    }
    
    enum Delete {
        case yes, no
        
        var note: String {
            switch self {
            case .yes: return NSLocalizedString("Delete", comment: "")
            case .no: return NSLocalizedString("Don't Delete", comment: "")
            }
        }
    }
    
    enum Verify {
        case yes, no
        
        var iCloud: String {
            switch self {
            case .yes: return NSLocalizedString("Verify", comment: "")
            case .no: return NSLocalizedString("Don't Verify", comment: "")
            }
        }
    }
}
