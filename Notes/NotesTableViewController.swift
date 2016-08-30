//
//  NotesTableViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/4/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//


import UIKit

class NotesTableViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    var notes = [Notes]()
    
    // MARK: - IBAction Methods
    
    @IBAction func unwindToNotesTableViewController(sender: UIStoryboardSegue) {
        guard let validNotesViewController = sender.source as? NotesViewController, let validNote = validNotesViewController.note else { return }
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.notes[selectedIndexPath.row] = validNote
            self.tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.none)
        }
        else {
            let newIndexPath = IndexPath(row: self.notes.count, section: 0)
            self.notes.append(validNote)
            self.tableView.insertRows(at: [newIndexPath], with: .bottom)
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
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.notes, toFile: Notes.archiveURL.path)
        if !isSuccessfulSave { print("unable to save note...") }
    }
    
    func loadNotes() -> [Notes]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Notes.archiveURL.path) as? [Notes]
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
    }

    // MARK: - UITableViewDataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        let note = self.notes[indexPath.row]
        
        cell.noteLabel.text = note.entry
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.notes.remove(at: indexPath.row)
            self.saveNotes()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNotesViewControllerFromCell" {
            guard let validNotesViewController = segue.destination as? NotesViewController,
                let selectedNoteCell = sender as? NotesTableViewCell,
                let selectedIndexPath = self.tableView.indexPath(for: selectedNoteCell) else { return }
            let selectedNote = self.notes[selectedIndexPath.row]
            validNotesViewController.note = selectedNote
        }
        else if segue.identifier == "segueToNotesViewControllerFromAddButton" {
            print("adding new note")
        }
    }
}
