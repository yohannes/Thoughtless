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
    
    let iCloudEnabledKey = "iCloudEnabled"
    let firstLaunchWithiCloudKey = "FirstLaunchWithiCloud"
    
    let ubiquityIdentityToken = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
    let currentiCloudToken = FileManager.default.ubiquityIdentityToken
    
    // MARK: - Helper Methods
    
    func iCloudAccountAvailabilityHasChanged() {
        print("iCloud account availability has changed.")
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
        
        // MARK: - iCloud Validation
        
//        UserDefaults.standard.set(true, forKey: self.firstLaunchWithiCloudKey)
        
        if let validCurrentiCloudToken = self.currentiCloudToken {
            let validCurrentiCloudTokenData = NSKeyedArchiver.archivedData(withRootObject: validCurrentiCloudToken)
            UserDefaults.standard.set(validCurrentiCloudTokenData, forKey: self.ubiquityIdentityToken)
            
            
            let firstLaunchWithiCloud = UserDefaults.standard.bool(forKey: self.firstLaunchWithiCloudKey)
            print("value of firstLaunchWithiCloud: \(String(describing: firstLaunchWithiCloud))")
            print("value of currentiCloudToken: \(String(describing: currentiCloudToken))")
            
            if firstLaunchWithiCloud == true && currentiCloudToken != nil {
                print("first launch: \(firstLaunchWithiCloud)")
                // Set up an alert controller without a view controller
                let topWindow = UIWindow(frame: UIScreen.main.bounds)
                topWindow.rootViewController = UIViewController()
                topWindow.windowLevel = UIWindowLevelAlert + 1
                
                let storageChoiceAlertController = UIAlertController(title: NSLocalizedString("Choose Storage Option", comment: ""),
                                                                     message: NSLocalizedString("Should notes be stored in iCloud & available on all your devices?", comment: ""),
                                                                     preferredStyle: .alert)
                let iCloudChoiceAlertAction = UIAlertAction(title: NSLocalizedString("Store in iCloud", comment: ""),
                                                            style: .default,
                                                            handler: { (_) in
                                                                UserDefaults.standard.set(true, forKey: self.iCloudEnabledKey)
                })
                let localChoiceAlertAction = UIAlertAction(title: NSLocalizedString("Store only in this device", comment: ""),
                                                           style: .cancel,
                                                           handler: { (_) in
                                                                UserDefaults.standard.set(false, forKey: self.iCloudEnabledKey)
                })
                storageChoiceAlertController.addAction(iCloudChoiceAlertAction)
                storageChoiceAlertController.addAction(localChoiceAlertAction)
                
                topWindow.makeKeyAndVisible()
                topWindow.rootViewController?.present(storageChoiceAlertController,
                                                      animated: true,
                                                      completion: { 
                                                        UserDefaults.standard.set(false, forKey: self.firstLaunchWithiCloudKey)
                })
            }
        }
        else {
            UserDefaults.standard.removeObject(forKey: self.ubiquityIdentityToken)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.iCloudAccountAvailabilityHasChanged),
                                               name: NSNotification.Name.NSUbiquityIdentityDidChange,
                                               object: nil)
    
//        let firstLaunchWithiCloud = UserDefaults.standard.bool(forKey: self.firstLaunchWithiCloudKey)
//        print("value of firstLaunchWithiCloud 2: \(String(describing: firstLaunchWithiCloud))")
//        print("value of currentiCloudToken: \(String(describing: currentiCloudToken))")
//        if currentiCloudToken != nil && firstLaunchWithiCloud == true {
//            let storageChoiceAlertController = UIAlertController(title: NSLocalizedString("Choose Storage Option", comment: ""),
//                                                                 message: NSLocalizedString("Should notes be stored in iCloud & available on all your devices?", comment: ""),
//                                                                 preferredStyle: .alert)
//            let iCloudChoiceAlertAction = UIAlertAction(title: NSLocalizedString("Store in iCloud", comment: ""),
//                                                        style: .default,
//                                                        handler: { (_) in
//                                                            UserDefaults.standard.set(true, forKey: self.iCloudEnabledKey)
//            })
//            let localChoiceAlertAction = UIAlertAction(title: NSLocalizedString("Store locally", comment: ""),
//                                                       style: .cancel,
//                                                       handler: nil)
//            storageChoiceAlertController.addAction(iCloudChoiceAlertAction)
//            storageChoiceAlertController.addAction(localChoiceAlertAction)
//            self.window?.rootViewController?.present(storageChoiceAlertController,
//                                                     animated: true,
//                                                     completion: nil)
//            UserDefaults.standard.set(false, forKey: self.firstLaunchWithiCloudKey)
//        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if self.currentiCloudToken != nil && UserDefaults.standard.bool(forKey: self.firstLaunchWithiCloudKey) == true { return }
        
        guard let validRootViewController = self.window?.rootViewController,
            validRootViewController.childViewControllers.count <= 1,
            let validNavigationControllerEmbeddedInNotesViewController = validRootViewController.storyboard?.instantiateViewController(withIdentifier: "NavigationControllerEmbeddedInNotesViewController") as? UINavigationController else { return }
        DispatchQueue.main.async {
            validRootViewController.present(validNavigationControllerEmbeddedInNotesViewController, animated: true, completion: nil)
        }
    }
}
