//
//  DetailViewController.swift
//  FeedEater
//
//  Created by Genius on 7/27/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView?
    var url: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if url != nil && webView != nil {
            var request: NSURLRequest = NSURLRequest(URL: url!)
            webView!.loadRequest(request)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if url != nil && webView != nil {
            var request: NSURLRequest = NSURLRequest(URL: url!)
            webView!.loadRequest(request)
        }

    }
}
