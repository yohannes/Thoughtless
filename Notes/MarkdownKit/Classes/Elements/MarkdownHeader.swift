//
//  MarkdownHeader.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//

import UIKit

open class MarkdownHeader: MarkdownLevelElement {

  fileprivate static let regex = "^(#{1,%@})\\s*(.+)$"
  
  fileprivate enum MarkdownHeadingElements: CGFloat {
    case oneHash = 6,
    twoHashes = 4,
    threeHashes = 2,
    fourHashes = 0,
    fiveHashes = -2,
    sixHashes = -4,
    zeroHash = -6
  }

  open var maxLevel: Int
  open var font: UIFont?
  open var color: UIColor?
  open var fontIncrease: Int

  open var regex: String {
    let level: String = maxLevel > 0 ? "\(maxLevel)" : ""
    return String(format: MarkdownHeader.regex, level)
  }

  public init(font: UIFont? = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
              maxLevel: Int = 0, fontIncrease: Int = 4, color: UIColor? = nil) {
    self.maxLevel = maxLevel
    self.font = font
    self.color = color
    self.fontIncrease = fontIncrease
  }

  open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
      attributedString.deleteCharacters(in: range)
  }

  open func attributesForLevel(_ level: Int) -> [String: AnyObject] {
    var attributes = self.attributes
    if let font = font {
      var actualLevel: CGFloat
      
      if case 0 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.oneHash.rawValue
      }
      else if case 1 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.twoHashes.rawValue
      }
      else if case 2 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.threeHashes.rawValue
      }
      else if case 3 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.fourHashes.rawValue
      }
      else if case 4 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.fiveHashes.rawValue
      }
      else if case 5 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.sixHashes.rawValue
      }
      else if case 6 = level {
        actualLevel = CGFloat(level) + MarkdownHeadingElements.zeroHash.rawValue
      }
      else {
        actualLevel = MarkdownHeadingElements.fourHashes.rawValue
      }
      
      let headerFontSize: CGFloat = font.pointSize + (actualLevel * CGFloat(fontIncrease))
      attributes[NSFontAttributeName] = font.withSize(headerFontSize)
    }
    return attributes
  }
}
