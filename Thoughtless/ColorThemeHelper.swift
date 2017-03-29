//
//  ColorThemeHelper.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 3/4/17.
//  Copyright © 2017 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SwiftHEXColors

struct ColorThemeHelper {
    static func reederGray(alpha value: Float = 1.0) -> UIColor {
        return UIColor(hex: 0x4B4A47, alpha: value)!
    }
    
    static func reederCream(alpha value: Float = 1.0) -> UIColor {
        return UIColor(hex: 0xE1E0D9, alpha: value)!
    }
    
    static func reederCharcoal(alpha value: Float = 1.0) -> UIColor {
        return UIColor(hex: 0x43423F, alpha: value)!
    }
    
    static func reederMud(alpha value: Float = 1.0) -> UIColor {
        return UIColor(hex: 0x353535, alpha: value)!
    }
}
