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
