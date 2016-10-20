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
      var actualLevel: CGFloat = 0
      if case 0 = level {
        actualLevel = CGFloat(level) + 6
      }
      else if case 1 = level {
        actualLevel = CGFloat(level) + 4
      }
      else if case 2 = level {
        actualLevel = CGFloat(level) + 2
      }
      else if case 3 = level {
        actualLevel = CGFloat(level) + 0
      }
      else if case 4 = level {
        actualLevel = CGFloat(level) - 2
      }
      else if case 5 = level {
        actualLevel = CGFloat(level) - 4
      }
      else if case 6 = level {
        actualLevel = CGFloat(level) - 6
      }
      else {
        actualLevel = 0
      }

      let headerFontSize: CGFloat = font.pointSize + (actualLevel * CGFloat(fontIncrease))
//      let headerFontSize: CGFloat = font.pointSize + (CGFloat(level) * CGFloat(fontIncrease))
//      print("font.pointSize:\(font.pointSize)")
//      print("trueLevel:\(actualLevel)")
//      print("headerFontSize: \(headerFontSize)")
//      print("level: \(level)")
//      print("fontIncrease: \(fontIncrease)")
//      print("***********************")
      attributes[NSFontAttributeName] = font.withSize(headerFontSize)
    }
    return attributes
  }
}
