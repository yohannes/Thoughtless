//
//  NoteSafariViewController.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 4/13/17.
//  Copyright © 2017 Yohannes Wijaya. All rights reserved.
//

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
