//
//  NotesTableViewCell.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 8/5/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteModificationTimeStampLabel: UILabel!
    
    // MARK: - UIViewController Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.noteLabel.textColor = UIColor(hexString: "#6F7B91")
        self.noteModificationTimeStampLabel.textColor = UIColor(hexString: "#72889E")
    }
}
