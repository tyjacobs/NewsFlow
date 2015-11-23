//
//  DetailViewController.swift
//  FeedEater
//
//  Created by Genius on 7/27/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import UIKit
import PKHUD
import WebKit

// this view controller is used when the user drills down into the detail for a story
class DetailViewController: UIViewController {

    var webView: WKWebView?
    var url: NSURL?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
        webView?.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        webView?.removeObserver(self, forKeyPath: "loading")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    func reload() {
        if let url = url, let webView = webView {
            let request: NSURLRequest = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {

        guard let keyPath = keyPath, let change = change else { return }
        
        if keyPath == "loading" {
            if let val = change[NSKeyValueChangeNewKey] as? Bool {
                if val {
                    PKHUD.sharedHUD.show()
                } else {
                    PKHUD.sharedHUD.hide()
                }
            }
        }
    }
}
