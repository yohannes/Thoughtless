//
//  MarkdownNotesWebViewController.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 3/26/17.
//  Copyright © 2017 Yohannes Wijaya. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class MarkdownNotesWebViewController: UIViewController {
    
    // MARK: -- Stored Properties
    
    var webView: WKWebView?
    var note: Note?
//    var lastOffsetY: CGFloat = 0
    
    // MARK: -- IBOutlet Properties
    
    @IBOutlet weak var containerView: UIView! = nil
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Markdown"
        
        let stylingSourceCode = "document.body.style.background = \"#4B4A47\"; document.body.style.fontFamily = \"AvenirNext-Regular\"; document.body.style.fontSize = \"3.0rem\"; document.body.style.color = \"#E1E0D9\"; document.body.style.padding = \"8px\";"
        let userScript = WKUserScript(source: stylingSourceCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView?.scrollView.backgroundColor = ColorThemeHelper.reederGray()
        self.webView?.allowsBackForwardNavigationGestures = true
//        self.webView?.scrollView.delegate = self
        self.view = self.webView
        
        guard let validNote = self.note else { return }
        let textAsHTML = MarkdownHelper().parse(validNote.entry)
        self.webView?.loadHTMLString(textAsHTML, baseURL: nil)
    }
}

//extension MarkdownNotesWebViewController: UIScrollViewDelegate {
//    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.lastOffsetY = scrollView.contentOffset.y
//    }
//    
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > self.lastOffsetY {
//            self.navigationController?.navigationBar.isHidden = true
//            self.markdownNotesTextViewTopEqualSuperviewTop.constant = -64
//        }
//        else {
//            self.navigationController?.navigationBar.isHidden = false
//            self.markdownNotesTextViewTopEqualSuperviewTop.constant = 0
//        }
//    }
//}
