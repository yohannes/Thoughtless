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
        
        self.noteLabel.textColor = ColorThemeHelper.reederCream()
        self.noteModificationTimeStampLabel.textColor = ColorThemeHelper.reederCream()
    }
}
