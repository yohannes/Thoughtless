//
//  NotesTableViewCell.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/5/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var noteLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
