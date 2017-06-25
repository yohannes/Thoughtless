
/*
 * MarkdownNotesWebViewController.swift
 * Thoughtless
 *
 * Created by Yohannes Wijaya on 3/26/17.
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
import WebKit
import SafariServices
import HidingNavigationBar

class MarkdownNotesWebViewController: UIViewController {
    
    // MARK: -- Stored Properties
    
    var webView: WKWebView?
    
    var note: Note?
    
    var hidingNavigationBarManager: HidingNavigationBarManager?
    
    // MARK: -- Helper Methods
    
    func handleScreenEdgePanGestureFromWebView(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .changed {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissMarkdownNotesWebViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: -- IBOutlet Properties
    
    @IBOutlet weak var containerView: UIView! = nil
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Markdown"
        
        self.navigationController?.isToolbarHidden = true
        
        let stylingSourceCode = "document.body.style.background = \"#4B4A47\"; document.body.style.fontFamily = \"AvenirNext-Regular\"; document.body.style.fontSize = \"3.0rem\"; document.body.style.color = \"#E1E0D9\"; document.body.style.margin = \"8px\";  document.body.style.padding = \"8px\";"
        let userScript = WKUserScript(source: stylingSourceCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView?.scrollView.backgroundColor = ColorThemeHelper.reederGray()
        
        guard let validNote = self.note else { return }
        let textAsHTML = MarkdownHelper().parse(validNote.entry)
        self.webView?.loadHTMLString(textAsHTML, baseURL: nil)
        
        self.webView?.scrollView.delegate = self
        self.view = self.webView
        
        self.webView?.navigationDelegate = self
        
        self.hidingNavigationBarManager = HidingNavigationBarManager(viewController: self, scrollView: self.webView!.scrollView)
        
        let swipeRightFromLeftGestureToCancelOrSave = UISwipeGestureRecognizer(target: self, action: #selector(MarkdownNotesWebViewController.dismissMarkdownNotesWebViewController))
        swipeRightFromLeftGestureToCancelOrSave.direction = .right
        self.webView?.addGestureRecognizer(swipeRightFromLeftGestureToCancelOrSave)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hidingNavigationBarManager?.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.hidingNavigationBarManager?.viewWillDisappear(animated)
    }
}

extension MarkdownNotesWebViewController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.hidingNavigationBarManager?.shouldScrollToTop()
        return true
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

extension MarkdownNotesWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let validURL = navigationAction.request.url else { return }
            let noteSafariViewController = NoteSafariViewController(url: validURL)
            noteSafariViewController.modalPresentationStyle = .overFullScreen
            self.present(noteSafariViewController, animated: true, completion: {
                decisionHandler(WKNavigationActionPolicy.cancel)
                let screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                                      action: #selector(MarkdownNotesWebViewController.handleScreenEdgePanGestureFromWebView(_:)))
                screenEdgePanGestureRecognizer.edges = .left
                noteSafariViewController.edgeView?.addGestureRecognizer(screenEdgePanGestureRecognizer)
            })
        }
        else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}


