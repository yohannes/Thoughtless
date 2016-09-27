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
    IQKeyboardManager.sharedManager().enable = true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    guard let validRootViewController = self.window?.rootViewController,
      validRootViewController.childViewControllers.count <= 1,
      let validNavigationControllerEmbeddedInNotesViewController = validRootViewController.storyboard?.instantiateViewController(withIdentifier: "NavigationControllerEmbeddedInNotesViewController") as? UINavigationController else { return }
    validRootViewController.present(validNavigationControllerEmbeddedInNotesViewController, animated: true, completion: nil)
  }
}

