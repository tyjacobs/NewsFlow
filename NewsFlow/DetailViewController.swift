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

    @IBOutlet weak var webView: WKWebView?
    var url: NSURL?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
    }
    
    func reload() {
        if let url = url, let webView = webView {
            let request: NSURLRequest = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
}
