//
//  NotesTableViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/4/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

// TODO: 1) Add Markdown Support. 4) launching the app will immediately present a new note for user to type in. 5) fix the text view height in notes view controller. 6) change font in text field to avenir next.


import UIKit

class NotesTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    var notes = [Notes]()
    
    // MARK: - IBAction Methods
    
    @IBAction func unwindToNotesTableViewController(sender: UIStoryboardSegue) {
        guard let validNotesViewController = sender.sourceViewController as? NotesViewController, validNote = validNotesViewController.note else { return }
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.notes[selectedIndexPath.row] = validNote
            self.tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
        else {
            let newIndexPath = NSIndexPath(forRow: self.notes.count, inSection: 0)
            self.notes.append(validNote)
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        }
        self.saveNotes()
    }
    
    // MARK: - Helper Methods
    
    func loadSampleNotes() {
        guard let firstNote = Notes(entry: "I am the top most note in the app and I am very happy to be where I am right now.") else { return }
        guard let secondNote = Notes(entry: "I may be the second note here but I am fighting my way up to be the first note in the app.") else { return }
        guard let thirdNote = Notes(entry: "I am very grateful to be in the third position. One should be content with what they achieve.") else { return }
        self.notes += [firstNote, secondNote, thirdNote]
    }
    
    // MARK: - NSCoding Methods
    
    func saveNotes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.notes, toFile: Notes.archiveURL.path!)
        if !isSuccessfulSave { print("unable to save note...") }
    }
    
    func loadNotes() -> [Notes]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Notes.archiveURL.path!) as? [Notes]
    }
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadedNotes = self.loadNotes() {
            self.notes = loadedNotes
        }
        else {
            self.loadSampleNotes()
        }
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    

    // MARK: - UITableViewDataSource Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotesTableViewCell", forIndexPath: indexPath) as! NotesTableViewCell

        let note = self.notes[indexPath.row]
        
        cell.noteLabel.text = note.entry

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.notes.removeAtIndex(indexPath.row)
            self.saveNotes()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToNotesViewControllerFromCell" {
            guard let validNotesViewController = segue.destinationViewController as? NotesViewController,
                selectedNoteCell = sender as? NotesTableViewCell,
                selectedIndexPath = self.tableView.indexPathForCell(selectedNoteCell) else  { return }
            let selectedNote = self.notes[selectedIndexPath.row]
            validNotesViewController.note = selectedNote
        }
        else if segue.identifier == "segueToNotesViewControllerFromAddButton" {
            print("adding new note")
        }
    }
}
