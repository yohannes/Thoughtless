
/*
 * AboutViewController.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 3/4/17.
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
import QuartzCore

class AboutViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var personalNoteLabel: UILabel!
    @IBOutlet weak var thirdPartyCreditsLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // MARK: - IBAction Methods
    
    @IBAction func doneButtonDidTouch(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorThemeHelper.reederGray()
        
        self.profilePicture.image = UIImage(named: "profilePicture")
        self.profilePicture.layer.cornerRadius = CGFloat(20)
        self.profilePicture.layer.borderColor = ColorThemeHelper.reederCream().cgColor
        self.profilePicture.layer.borderWidth = CGFloat(2)
        self.profilePicture.clipsToBounds = true
        
        self.personalNoteLabel.textColor = ColorThemeHelper.reederCream()
        self.personalNoteLabel.text = "Crafted with countless hair-pulling & head-banging in Jakarta.\n---\nForemost gratitude to God, huge love to my fiancée; Karina & big 4 to my Milestone L37 buddies; Adrian, Alan, Azi, Daniel, Douglas, Harvey, Ivan, May Leng, Rex, Roland, Shiyun, Vincent, Wei Lik, Yasha, & Zoey.\n---"
        
        self.thirdPartyCreditsLabel.textColor = ColorThemeHelper.reederCream()
        self.thirdPartyCreditsLabel.text = "Credits to these awesome libraries & icons:\nCFAlertViewController by Crowdfire.\nHidingNavigationBar by Tristan Himmelman.\nIQKeyboardManager by Mohd Iftekhar Qurashi.\nSwiftHEXColors by Thi.\nApp icon by Freepik & In-app icons by Icons8.\n---"
        
        self.copyrightLabel.textColor = ColorThemeHelper.reederCream()
        self.copyrightLabel.text = "Copyright © 2017 Yohannes Wijaya. All respective rights reserved."
        
        let swipeDownGestureToDismissSelf = UISwipeGestureRecognizer(target: self, action: #selector(AboutViewController.dismissSelf))
        swipeDownGestureToDismissSelf.direction = .down
        self.view.addGestureRecognizer(swipeDownGestureToDismissSelf)
        
        let swipeRightFromLeftGestureToDismissSelf = UISwipeGestureRecognizer(target: self, action: #selector(AboutViewController.dismissSelf))
        swipeRightFromLeftGestureToDismissSelf.direction = .right
        self.view.addGestureRecognizer(swipeRightFromLeftGestureToDismissSelf)
    }
    
    // MARK: - Helper Methods
    
    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

}
