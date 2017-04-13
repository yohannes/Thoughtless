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
