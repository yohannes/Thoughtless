//
//  MarkdownNotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 9/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class MarkdownNotesViewController: UIViewController {
  
  // MARK: - Stored Properties
  
  var note: Notes?
  
  // MARK: - IBOutlet Properties
  
  @IBOutlet weak var markdownNotesTextView: UITextView! {
    didSet {
      guard let validNote = self.note else { return }
      let markdownNote = SwiftyMarkdown(string: validNote.entry)
      markdownNote.body.fontName = "AvenirNext-Regular"
      markdownNote.h1.color = UIColor.red
      markdownNote.h1.fontName = "AvenirNext-Bold"
      self.markdownNotesTextView.attributedText = markdownNote.attributedString()
    }
  }
}
