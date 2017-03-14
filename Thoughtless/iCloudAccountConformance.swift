//
//  iCloudAccountConformance.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 3/14/17.
//  Copyright © 2017 Yohannes Wijaya. All rights reserved.
//

import UIKit

protocol iCloudAccountConformance {
    var currentToken: (NSCoding, NSCopying, NSObjectProtocol)? { get }
    var tokenIdentifier: String { get }
    
    func validateConfiguration(from: UIViewController)
//    func iCloudAccountAvailabilityHasChanged()
}

extension iCloudAccountConformance {
//    func icloudAccountAvailabilityHasChanged() {
//        print("iCloud account has changed. Old:\(String(describing: currentToken)). New: \(String(describing: FileManager.default.ubiquityIdentityToken))")
//    }
    
    func validateConfiguration(from viewController: UIViewController) {
        if let validCurrentToken = currentToken {
            let currentTokenData = NSKeyedArchiver.archivedData(withRootObject: validCurrentToken)
            UserDefaults.standard.set(currentTokenData, forKey: tokenIdentifier)
        }
        else {
            UserDefaults.standard.removeObject(forKey: tokenIdentifier)
            
            // Set up an alert controller without a view controller
            let topWindow = UIWindow(frame: UIScreen.main.bounds)
            topWindow.rootViewController = UIViewController()
            topWindow.windowLevel = UIWindowLevelAlert + 1
            
            let iCloudUnsetAlertController = UIAlertController(title: "Missing iCloud Account",
                                                               message: "Thoughtless requires iCloud to sync your notes.",
                                                               preferredStyle: .alert)
            let goToiCloudSettingAlertAction = UIAlertAction(title: "Set Up iCloud Now",
                                                             style: .default,
                                                             handler: { (_) in
                                                                guard let iCloudSettingURL = URL(string: "App-Prefs:root=CASTLE") else { return }
                                                                UIApplication.shared.openURL(iCloudSettingURL)
                                                                topWindow.isHidden = true
            })
            iCloudUnsetAlertController.addAction(goToiCloudSettingAlertAction)
            
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.present(iCloudUnsetAlertController,
                                                  animated: true,
                                                  completion: nil)
        }
        
        // Registering for iCloud availability change notifications
//        NotificationCenter.default.addObserver(viewController,
//                                               selector: #selector(AppDelegate.iCloudAccountAvailabilityHasChanged),
//                                               name: .NSUbiquityIdentityDidChange,
//                                               object: nil)
    }
}
