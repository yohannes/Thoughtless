
/*
 * NoteSafariViewController.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 4/13/17.
 * Copyright © 2017 Yohannes Wijaya. All respective rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit
import SafariServices

class NoteSafariViewController: SFSafariViewController {
    
    // MARK: - Stored Properties
    
    private var _edgeView: UIView?
    
    var edgeView: UIView? {
        get {
            if self._edgeView == nil && self.isViewLoaded {
                self._edgeView = UIView()
                self._edgeView?.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(self._edgeView!)
                self._edgeView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.005)
                
                let bindings = ["edgeView": _edgeView!]
                let layoutFormatOptions = NSLayoutFormatOptions(rawValue: 0)
                let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[edgeView(5)]",
                                                                  options: layoutFormatOptions,
                                                                  metrics: nil,
                                                                  views: bindings)
                let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[edgeView]-0-|",
                                                                  options: layoutFormatOptions,
                                                                  metrics: nil,
                                                                  views: bindings)
                
                self.view.addConstraints(hConstraints)
                self.view.addConstraints(vConstraints)
            }
            return self._edgeView
        }
    }
    
    // MARK: - UIViewController Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
}
