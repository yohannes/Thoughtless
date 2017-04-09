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
    
    
    // MARK: - Helper Methods
    
    fileprivate func changeUITableViewRowActionButtonFontColor() {
        for subview in self.subviews {
            for subsubview in subview.subviews {
                if (String(describing: subsubview).range(of: "UITableViewCellActionButton") != nil) {
                    if let tableViewRowActionButton = subsubview as? UIButton {
                        tableViewRowActionButton.setTitleColor(ColorThemeHelper.reederCream(), for: .normal)
                    }
                }
            }
        }
    }
    
    // MARK: - UIView Methods
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.changeUITableViewRowActionButtonFontColor()
    }
    
    // MARK: - UIViewController Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.noteLabel.textColor = ColorThemeHelper.reederCream()
        self.noteModificationTimeStampLabel.textColor = ColorThemeHelper.reederCream()
    }
    
}
