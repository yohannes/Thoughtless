//
//  AppDelegate.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 8/4/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Stored Properties
    
    var window: UIWindow?
    
    let iCloudIdentityToken = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
    
    // MARK: - UIApplicationDelegate Methods
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.backgroundColor = UIColor(hex: 0x25282C)
        
        UINavigationBar.appearance().barTintColor = UIColor(hex: 0x25282C)
        UINavigationBar.appearance().tintColor = UIColor(hex: 0x488AC6)
        UINavigationBar.appearance().barStyle = .blackTranslucent
        UINavigationBar.appearance().isTranslucent = false
        
        UIToolbar.appearance().barTintColor = UIColor(hexString: "#25282C")
        UIToolbar.appearance().tintColor = UIColor(hexString: "#488AC6")
        UIToolbar.appearance().isTranslucent = false
        
        UITableView.appearance().backgroundColor = UIColor(hex: 0x25282C)
        
        UITableViewCell.appearance().backgroundColor = UIColor(hex: 0x25282C)
        
        UITextView.appearance().backgroundColor = UIColor(hex: 0x25282C)
        
        IQKeyboardManager.sharedManager().enable = true
        
        // TODO: - Add logic to prepare app to use iCloud & handle changes in iCloud availability
        /***
        // Check for iCloud availability
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else { return }
            
            // Obtain iCloud token
            let iCloudCurrentToken = FileManager.default.ubiquityIdentityToken
            
            // Archive iCloud availability in the user defaults database
            if let validiCloudCurrentToken = iCloudCurrentToken {
                let newTokenData = NSKeyedArchiver.archivedData(withRootObject: validiCloudCurrentToken)
                UserDefaults.standard.set(newTokenData, forKey: weakSelf.iCloudIdentityToken)
            }
            else {
                UserDefaults.standard.removeObject(forKey: weakSelf.iCloudIdentityToken)
            }
            
            // Register for iCloud notification to detect when user signs in / out of iCloud
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(iCloudAccountAvailaibilityChanged),
                                                   name: NSUbiquityIdentityDidChange,
                                                   object: nil)
        }
        ***/
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let validRootViewController = self.window?.rootViewController,
            validRootViewController.childViewControllers.count <= 1,
            let validNavigationControllerEmbeddedInNotesViewController = validRootViewController.storyboard?.instantiateViewController(withIdentifier: "NavigationControllerEmbeddedInNotesViewController") as? UINavigationController else { return }
        DispatchQueue.main.async {
            validRootViewController.present(validNavigationControllerEmbeddedInNotesViewController, animated: true, completion: nil)
        }
    }
}

