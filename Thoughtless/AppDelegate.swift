
/* 
 * AppDelegate.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 8/4/16.
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
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Stored Properties
    
    var window: UIWindow?
    
    let iCloudEnabledKey = "iCloudEnabled"
    let hasLaunchedWithiCloudBeforeKey = "hasLaunchedWithiCloudBefore"
    let storeIniCloudKey = "Store in iCloud"
    let storeOnlyInThisDeviceKey = "Store only in this device"
    
    let ubiquityIdentityToken = "org.corruptionofconformity.thoughtless.UbiquityIdentityToken"
    let currentiCloudToken = FileManager.default.ubiquityIdentityToken
    
    // MARK: - Helper Methods
    
    func iCloudAccountAvailabilityHasChanged() {
        print("iCloud account availability has changed. [AppDelegate]")
        guard let archivediCloudTokenData = UserDefaults.standard.data(forKey: self.ubiquityIdentityToken), let archivediCloudTokenRaw = NSKeyedUnarchiver.unarchiveObject(with: archivediCloudTokenData) as? (NSCoding & NSCopying & NSObjectProtocol) else { return }
        if !archivediCloudTokenRaw.isEqual(FileManager.default.ubiquityIdentityToken) {
            // Update iCloud token & rescan docs
            print("Different iCloud account detected.")
        }
    }
    
    // MARK: - UIApplicationDelegate Methods
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window?.backgroundColor = ColorThemeHelper.reederGray()
        
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).barTintColor = ColorThemeHelper.reederGray()
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).tintColor = ColorThemeHelper.reederCream()
        
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).barStyle = .black
        UINavigationBar.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).isTranslucent = false
        
        UIScrollView.appearance().indicatorStyle = .white
        
        UIToolbar.appearance().barTintColor = ColorThemeHelper.reederGray()
        UIToolbar.appearance().tintColor =  ColorThemeHelper.reederCream()
        UIToolbar.appearance().isTranslucent = false
        
        UITableView.appearance().backgroundColor = ColorThemeHelper.reederGray()

        UITableViewCell.appearance(whenContainedInInstancesOf: [NotesNavigationControler.self]).backgroundColor = ColorThemeHelper.reederGray()
        
        UITextField.appearance().tintColor = ColorThemeHelper.reederCream()
        
        UITextView.appearance().backgroundColor = ColorThemeHelper.reederGray()
        UITextView.appearance().tintColor = ColorThemeHelper.reederCream()
        
        IQKeyboardManager.sharedManager().enable = true
        
        // MARK: - iCloud Validation
        
        if let validCurrentiCloudToken = self.currentiCloudToken {
            let validCurrentiCloudTokenData = NSKeyedArchiver.archivedData(withRootObject: validCurrentiCloudToken)
            UserDefaults.standard.set(validCurrentiCloudTokenData, forKey: self.ubiquityIdentityToken)
            
            let hasLaunchedWithiCloudBefore = UserDefaults.standard.bool(forKey: self.hasLaunchedWithiCloudBeforeKey)
            
            if hasLaunchedWithiCloudBefore == false && currentiCloudToken != nil {
                // Set up an alert controller without a view controller
                let topWindow = UIWindow(frame: UIScreen.main.bounds)
                topWindow.rootViewController = UIViewController()
                topWindow.windowLevel = UIWindowLevelAlert + 1
                
                let storageChoiceAlertController = UIAlertController(title: NSLocalizedString("Choose Storage Option", comment: ""),
                                                                     message: NSLocalizedString("Should notes be stored in iCloud & available in all of your devices?", comment: ""),
                                                                     preferredStyle: .alert)
                let iCloudChoiceAlertAction = UIAlertAction(title: NSLocalizedString("Store in iCloud", comment: ""),
                                                            style: .default,
                                                            handler: { (_) in
                                                                UserDefaults.standard.set(true, forKey: self.iCloudEnabledKey)
                                                                if let notesTableViewController = self.window?.rootViewController?.childViewControllers.first as? NotesTableViewController {
                                                                    notesTableViewController.verifyiCloudAccount()
                                                                }
                })
//                let localChoiceAlertAction = UIAlertAction(title: NSLocalizedString("Store only in this device", comment: ""),
//                                                           style: .cancel,
//                                                           handler: { (_) in
//                                                                UserDefaults.standard.set(false, forKey: self.iCloudEnabledKey)
//                })
//                localChoiceAlertAction.isEnabled = false
                storageChoiceAlertController.addAction(iCloudChoiceAlertAction)
//                storageChoiceAlertController.addAction(localChoiceAlertAction)
                
                topWindow.makeKeyAndVisible()
                topWindow.rootViewController?.present(storageChoiceAlertController,
                                                      animated: true,
                                                      completion: { 
                                                        UserDefaults.standard.set(true, forKey: self.hasLaunchedWithiCloudBeforeKey)
                })
            }
        }
        else {
            UserDefaults.standard.removeObject(forKey: self.ubiquityIdentityToken)
        }
        
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.iCloudAccountAvailabilityHasChanged),
                                               name: NSNotification.Name.NSUbiquityIdentityDidChange,
                                               object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if UserDefaults.standard.bool(forKey: self.hasLaunchedWithiCloudBeforeKey) == false { return }
        
        guard let validRootViewController = self.window?.rootViewController,
            validRootViewController.childViewControllers.count <= 1,
            let validNavigationControllerEmbeddedInNotesViewController = validRootViewController.storyboard?.instantiateViewController(withIdentifier: "NavigationControllerEmbeddedInNotesViewController") as? UINavigationController else { return }
        DispatchQueue.main.async {
            validRootViewController.present(validNavigationControllerEmbeddedInNotesViewController, animated: true, completion: nil)
        }
    }
}
