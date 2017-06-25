
/*
 * NotesTableViewController.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 8/4/16.
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
import CFAlertViewController

class NotesTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    let addButtonAssetName = "icons8-Plus-22"

    var noteDocuments = [NoteDocument]() {
        didSet {
            self.refreshNoteCount()
        }
    }
    var filteredNoteDocuments = [NoteDocument]()
    
    var metadataQuery = NSMetadataQuery()
    
    var tableViewRefreshControl: UIRefreshControl!
    
    var ubiquityIdentityToken = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
    let iCloudEnabledKey = "iCloudEnabled"
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var correctScrollingPosition: CGPoint = CGPoint(x: 0, y: 0)
    
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
        self.correctScrollingPosition = CGPoint(x: 0, y: (self.tableView.tableHeaderView?.frame.size.height)!)
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
    
    fileprivate func configureAddBarButtonItemOnToolbar() {
        let addBarButtonItem = UIBarButtonItem(image: UIImage(named: self.addButtonAssetName), style: .plain, target: self, action: #selector(NotesTableViewController.performSegueFromAddButtonToNotesViewController))
        let flexibleSpaceBarButtonSystemItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setToolbarItems([flexibleSpaceBarButtonSystemItem,addBarButtonItem, flexibleSpaceBarButtonSystemItem], animated: false)
        self.navigationController?.isToolbarHidden = false
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
    
    fileprivate func dismissSearchBar() {
        self.searchController.searchBar.resignFirstResponder()
        self.tableView.setContentOffset(CGPoint(x: 0, y: (self.tableView.tableHeaderView?.frame.size.height)!),
                                        animated: true)
    }
    
    fileprivate func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredNoteDocuments = self.noteDocuments.filter { (noteDocument: NoteDocument) -> Bool in
            return noteDocument.note.entry.lowercased().contains(searchText.lowercased())
        }
        self.tableView.reloadData()
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
        guard let firstNote = Note(entry: "## Power up your note:\n---\n\nMake a todo list:\n\n- Watch **WWDC 2017** keynote[(video url)](http://www.apple.com/apple-events/june-2017/).\n* Write `code`.👨🏻‍💻\n\n1. Build codebase.\n2. Refactor `code`.\n\nMake a check list:\n\n- [ ] Debug ~~master~~ *feature* branch.\n- [ ] _Rebuild_ project.\n\nCreate a block of quote:\n\n>_\"Be yourself. Everyone else is already taken.\"_ -Oscar Wilde\n\nOr a bunch of codes too:\n\n```\nlet printMe: () -> Void {\n   print(\"I am called Thoughtless\")\n}```\n\nTap *Preview* to see your enhanced note.\n\nTap *Markdown* to access tutorial.", dateOfCreation: self.getCurrentDateAndTime()) else { return }
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
    
    func performSegueFromAddButtonToNotesViewController() {
        self.performSegue(withIdentifier: NotesTableViewControllerSegue.segueToNotesViewControllerFromAddButton.rawValue, sender: self)
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
    
    fileprivate func returnCorrectTableViewSCrollingPosition() {
        // When UISearchController is visible, hide it upon return to UITableView
        if self.tableView.contentOffset.y == 0 {
            // Therefore, scroll the 1st table view row to be just below the navigation bar when returning.
            self.tableView.setContentOffset(CGPoint(x: 0, y: (self.tableView.tableHeaderView?.frame.size.height)!), animated: true)
        }
        else {
            // Return to the previous scrolling position
            self.tableView.setContentOffset(self.correctScrollingPosition, animated: true)
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
    
    fileprivate func setupSearchBar() {
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.searchController.searchBar.placeholder = NSLocalizedString("Search My Past Thoughts", comment: "")
        self.searchController.searchBar.searchBarStyle = .minimal
        guard let textFieldWithinSearchBar = self.searchController.searchBar.value(forKey: "searchField") as? UITextField else { return }
        textFieldWithinSearchBar.borderStyle = .none
        textFieldWithinSearchBar.backgroundColor = ColorThemeHelper.reederCharcoal()
        textFieldWithinSearchBar.layer.cornerRadius = 6.0
        textFieldWithinSearchBar.layer.masksToBounds = true
        textFieldWithinSearchBar.textColor = ColorThemeHelper.reederCream()
        self.searchController.searchBar.tintColor = ColorThemeHelper.reederCream()
        self.searchController.searchBar.delegate = self
        
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
    }
    
    func verifyiCloudAccount() {
        guard UserDefaults.standard.bool(forKey: self.iCloudEnabledKey) == true else { return }
        
        guard let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            let iCloudConfigurationAlertViewController = CFAlertViewController.alertController(title: NSLocalizedString("Misconfigured iCloud Account", comment: ""),
                                                                                               message: NSLocalizedString("You have set Thoughtless to sync your notes via iCloud. ENsure you sign in to iCloud & iCloud Drive is turned on.", comment: ""),
                                                                                               textAlignment: .center,
                                                                                               preferredStyle: .actionSheet,
                                                                                               didDismissAlertHandler: nil)
            let verifyiCloudConfigurationAlertViewAction = CFAlertAction.action(title: NSLocalizedString(Verify.yes.iCloud, comment: ""),
                                                                          style: .Default,
                                                                          alignment: .justified,
                                                                          backgroundColor: ColorThemeHelper.reederCharcoal(),
                                                                          textColor: ColorThemeHelper.reederCream(), handler: { (_) in
                                                                            guard let iCloudSettingURL = URL(string: "App-Prefs:root=CASTLE") else { return }
                                                                            UIApplication.shared.openURL(iCloudSettingURL)
            })
            let dontVerifyiCloudConfigurationAlertViewAction = CFAlertAction.action(title: NSLocalizedString(Verify.no.iCloud, comment: ""),
                                                                                style: .Default,
                                                                                alignment: .justified,
                                                                                backgroundColor: ColorThemeHelper.reederGray(),
                                                                                textColor: ColorThemeHelper.reederCream(), handler: nil)
            iCloudConfigurationAlertViewController.shouldDismissOnBackgroundTap = false
            iCloudConfigurationAlertViewController.addAction(verifyiCloudConfigurationAlertViewAction)
            iCloudConfigurationAlertViewController.addAction(dontVerifyiCloudConfigurationAlertViewAction)
            self.present(iCloudConfigurationAlertViewController, animated: true, completion: nil)
            return
        }
        self.loadNotes()
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ColorThemeHelper.reederCream()]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        self.tableView.separatorColor = ColorThemeHelper.reederCream(alpha: 0.05)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.tableView.backgroundView = UIView()
        
        self.tableViewRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = ColorThemeHelper.reederCream()
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
        
        self.setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureAddBarButtonItemOnToolbar()
        
        self.searchController.searchBar.resignFirstResponder()
        
        self.returnCorrectTableViewSCrollingPosition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.isActive = false
        
        self.correctScrollingPosition = self.tableView.contentOffset
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
            let selectedNote = self.searchController.isActive && self.searchController.searchBar.text != "" ? self.filteredNoteDocuments[selectedIndexPath.row].note : self.noteDocuments[selectedIndexPath.row].note
            validNotesViewController.note = selectedNote
        default:
            return
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchController.isActive && self.searchController.searchBar.text != "" ? self.filteredNoteDocuments.count : self.noteDocuments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        let noteDocument = self.searchController.isActive && self.searchController.searchBar.text != "" ? self.filteredNoteDocuments[indexPath.row] : self.noteDocuments[indexPath.row]
        
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
                let shouldDeleteAlertViewController = CFAlertViewController.alertController(title: NSLocalizedString("Delete For Sure?",
                                                                                                                     comment: ""),
                                                                                            message: NSLocalizedString("There is no way to recover it!", comment: ""),
                                                                                            textAlignment: .center,
                                                                                            preferredStyle: .actionSheet,
                                                                                            didDismissAlertHandler: nil)
                let deleteAlertViewAction = CFAlertAction.action(title: NSLocalizedString(Delete.yes.note, comment: ""),
                                                                 style: .Destructive,
                                                                 alignment: .justified,
                                                                 backgroundColor: ColorThemeHelper.vividRed(),
                                                                 textColor: ColorThemeHelper.reederCream(),
                                                                 handler: { (_) in
                                                                    weakSelf.deleteNote(at: indexPath)
                })
                let dontDeleteAlertViewAction = CFAlertAction.action(title: NSLocalizedString(Delete.no.note, comment: ""),
                                                                     style: .Default,
                                                                     alignment: .justified,
                                                                     backgroundColor: ColorThemeHelper.reederCharcoal(),
                                                                     textColor: ColorThemeHelper.reederCream(),
                                                                     handler: { (_) in
                                                                        weakSelf.setEditing(false, animated: true)
                })
                shouldDeleteAlertViewController.shouldDismissOnBackgroundTap = false
                shouldDeleteAlertViewController.addAction(deleteAlertViewAction)
                shouldDeleteAlertViewController.addAction(dontDeleteAlertViewAction)
                weakSelf.present(shouldDeleteAlertViewController, animated: true, completion: nil)
                
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
        case segueToAboutViewController
    }
    
    enum Delete {
        case yes, no
        
        var note: String {
            switch self {
            case .yes: return NSLocalizedString("DELETE", comment: "")
            case .no: return NSLocalizedString("DON'T DELETE", comment: "")
            }
        }
    }
    
    enum Verify {
        case yes, no
        
        var iCloud: String {
            switch self {
            case .yes: return NSLocalizedString("VERIFY", comment: "")
            case .no: return NSLocalizedString("DON'T VERIFY", comment: "")
            }
        }
    }
}

// MARK: - UISearchBarDelegate Protocol 

extension NotesTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismissSearchBar()
    }
}

// MARK: - UISearchResultUpdating Protocol

extension NotesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        self.filterContentForSearchText(searchBarText)
    }
}
