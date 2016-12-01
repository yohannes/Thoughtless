//
//  AppDelegate.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/4/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: - Stored Properties
  
  var window: UIWindow?
  
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

