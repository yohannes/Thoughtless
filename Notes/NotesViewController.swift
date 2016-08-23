//
//  NotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - IBAction Properties
    
    @IBAction func cancelButtonDidTouch(sender: UIBarButtonItem) {
        self.textView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonDidTouch(sender: UIBarButtonItem) {
        // TODO: impelement protocol to save whatever is in the textfield to the table view before dismissing view controller
    }
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.becomeFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
