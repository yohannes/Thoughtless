//
//  MarkdownNotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 9/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SafariServices

class MarkdownNotesViewController: UIViewController, UITextViewDelegate {
  
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
  
  // MARK: - UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.markdownNotesTextView.delegate = self
  }
  
  // MARK: - UITextFieldDelegate Methods
  
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    let safariViewController = SFSafariViewController(url: URL)
    self.present(safariViewController, animated: true, completion: nil)
    return false
  }
}
