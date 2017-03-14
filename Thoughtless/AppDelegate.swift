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
    
    // Obtaining the iCloud token
//    var currentiCloudToken: (NSCoding, NSCopying, NSObjectProtocol)?
    
//    let iCloudTokenIdentifer = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
    
    // MARK: - Helper Methods
    
    func iCloudAccountAvailabilityHasChanged() {
        print("iCloud account has changed. Old:\(String(describing: self.currentiCloudToken)). New: \(String(describing: FileManager.default.ubiquityIdentityToken as? (NSCoding, NSCopying, NSObjectProtocol)))")
    }
    
    // MARK: - UIApplicationDelegate Methods
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.backgroundColor = ColorThemeHelper.reederGray()
        
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).barTintColor = ColorThemeHelper.reederGray()
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).tintColor = ColorThemeHelper.reederCream()
        
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).barStyle = .black
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).isTranslucent = false
        
        UIToolbar.appearance().barTintColor = ColorThemeHelper.reederGray()
        UIToolbar.appearance().tintColor =  ColorThemeHelper.reederCream()
        UIToolbar.appearance().isTranslucent = false
        
        UITableView.appearance().backgroundColor = ColorThemeHelper.reederGray()

        UITableViewCell.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).backgroundColor = ColorThemeHelper.reederGray()
        
        UITextView.appearance().backgroundColor = ColorThemeHelper.reederGray()
        
        IQKeyboardManager.sharedManager().enable = true

        // TODO: - Add logic to prepare app to use iCloud & handle changes in iCloud availability
        
        self.currentiCloudToken = FileManager.default.ubiquityIdentityToken as? (NSCoding, NSCopying, NSObjectProtocol)
        
        self.validateConfiguration(from: <#T##UIViewController#>)
        
        //  Archiving iCloud availability in the user defaults database
//        if let validCurrentiCloudToken = self.currentiCloudToken {
//            print("Valid iCloud Token found: \(validCurrentiCloudToken)")
//            let currentiCloudTokenData = NSKeyedArchiver.archivedData(withRootObject: validCurrentiCloudToken)
//            UserDefaults.standard.set(currentiCloudTokenData, forKey: self.iCloudTokenIdentifer)
//        }
//        else {
//            UserDefaults.standard.removeObject(forKey: self.iCloudTokenIdentifer)
//            
//            // Set up an alert controller without a view controller
//            let topWindow = UIWindow(frame: UIScreen.main.bounds)
//            topWindow.rootViewController = UIViewController()
//            topWindow.windowLevel = UIWindowLevelAlert + 1
//            
//            let iCloudUnsetAlertController = UIAlertController(title: "Missing iCloud Account",
//                                                    message: "Thoughtless requires iCloud to sync your notes.",
//                                                    preferredStyle: .alert)
//            let goToiCloudSettingAlertAction = UIAlertAction(title: "Set Up iCloud Now",
//                                                             style: .default,
//                                                             handler: { (_) in
//                                                                guard let iCloudSettingURL = URL(string: "App-Prefs:root=CASTLE") else { return }
//                                                                UIApplication.shared.openURL(iCloudSettingURL)
//                                                                topWindow.isHidden = true
//            })
//            iCloudUnsetAlertController.addAction(goToiCloudSettingAlertAction)
//            
//            topWindow.makeKeyAndVisible()
//            topWindow.rootViewController?.present(iCloudUnsetAlertController,
//                                                  animated: true,
//                                                  completion: nil)
//        }
        
        // Registering for iCloud availability change notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.iCloudAccountAvailabilityHasChanged),
                                               name: .NSUbiquityIdentityDidChange,
                                               object: nil)
        
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
        
        guard let _ = self.currentiCloudToken else { return }
        guard let validRootViewController = self.window?.rootViewController,
            validRootViewController.childViewControllers.count <= 1,
            let validNavigationControllerEmbeddedInNotesViewController = validRootViewController.storyboard?.instantiateViewController(withIdentifier: "NavigationControllerEmbeddedInNotesViewController") as? UINavigationController else { return }
        DispatchQueue.main.async {
            validRootViewController.present(validNavigationControllerEmbeddedInNotesViewController, animated: true, completion: nil)
        }
    }
}

extension AppDelegate: iCloudAccountConformance {
    var currentToken = FileManager.default.ubiquityIdentityToken
    var tokenIdentifier = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
}
