//
//  NewsFlowTests.swift
//  NewsFlowTests
//
//  Created by Genius on 7/27/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import UIKit
import XCTest
import NewsFlow

class NewsFlowTests: XCTestCase, StoryListener {
    
    private var tableViewController: StoryTableViewController?
    override func setUp() {
        super.setUp()
        let appDelegate = UIApplication.sharedApplication().delegate
        if let vc = appDelegate?.window??.rootViewController {
            if let nvc = vc as? UINavigationController {
                tableViewController = nvc.viewControllers[0] as? StoryTableViewController
                if tableViewController == nil {
                    XCTFail("top view controller is not the main table controller")
                }
            }
            else {
                XCTFail("root view controller is not a navigation controller")
            }
        }
        else {
            XCTFail("failed to find root view controller")
        }
    }
    
    override func tearDown() {
        tableViewController = nil
        super.tearDown()
    }
    
    func testNetworkConnectivity() {
        let connected = StoryManager.sharedInstance.connectedToNetwork
        XCTAssert(connected, "not connected to network as expected")
    }
    
    func testTableExistsAndHasContent() {
        // "existence" is tested in setUp()
        let numberOfRows = tableViewController!.tableView.numberOfRowsInSection(0)
        XCTAssertGreaterThan(numberOfRows, 0, "number of rows is less than one")
    }
    
    var storyManagerRetrievalExpectation: XCTestExpectation?
    func testStoryManagerRespondsToListenersQuickly() {
        storyManagerRetrievalExpectation = self.expectationWithDescription("got callback from StoryManager")
        
        StoryManager.sharedInstance.addListener(self)
        StoryManager.sharedInstance.retrieveAllNewsItems()
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
        storyManagerRetrievalExpectation = nil
    }
    
    // this is part of testStoryManagerRespondsToListenersQuickly()
    // it is called asynchronously by StoryManager
    func storiesChanged() {
        storyManagerRetrievalExpectation?.fulfill()
    }
    
    func networkConnected() {
        // TODO
    }
    
    var tableReloadExpectation: XCTestExpectation?
    var tableReloadTimer: NSTimer?
    func testTableReload() {
        tableReloadExpectation = self.expectationWithDescription("table update completed")

        tableViewController?.reloadStories()

        tableReloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("checkForReloadComplete"), userInfo: nil, repeats: true)
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    // this is part of testTableReload()
    func checkForReloadComplete() {
        if tableViewController?.reloading == false {
            tableReloadTimer?.invalidate()
            tableReloadExpectation?.fulfill()
        }
    }
    
    private let sampleContent = "<table border=\"0\" cellpadding=\"2\" cellspacing=\"7\" style=\"vertical-align:top\"><tr><td width=\"80\" align=\"center\" valign=\"top\"><font style=\"font-size:85%;font-family:arial,sans-serif\"><a href=\"http://news.google.com/news/url?sa=t&amp;fd=R&amp;ct2=us&amp;usg=AFQjCNE7F1crOaeWDWEGKqT83Nn2LySGug&amp;clid=c3a7d30bb8a4878e06b80cf16b898331&amp;cid=52778912749235&amp;ei=02y5VaD7C6K7wQHd64CYCQ&amp;url=http://www.philly.com/philly/news/politics/20150730_As_Fattah_vows_to_stay_in_office__possible_successors_emerge.html\"><img src=\"//www.simplegeniussoftware.com/_Media/sgprojectpromacicon256.png\" alt=\"\" border=\"1\" width=\"80\" height=\"80\"><br><font size=\"-2\">Philly.com</font></a></font></td><td valign=\"top\"><font style=\"font-size:85%;font-family:arial,sans-serif\"><br><div style=\"padding-top:0.8em\"><img alt=\"\" height=\"1\" width=\"1\"></div><div><a href=\"http://news.google.com/news/url?sa=t&amp;fd=R&amp;ct2=us&amp;usg=AFQjCNE7F1crOaeWDWEGKqT83Nn2LySGug&amp;clid=c3a7d30bb8a4878e06b80cf16b"
    
    private let correctURL = "http://www.simplegeniussoftware.com/_Media/sgprojectpromacicon256.png"
    func testImageURLCreation() {
        let imageURL = tableViewController?.getImageURL(sampleContent)
        XCTAssertEqual(imageURL!.absoluteString, correctURL, "getImageURL failed to parse and generate a valid URL")
    }
    
    var imageDownloadExpectation: XCTestExpectation?
    var imageDownloadTimer: NSTimer?
    var uiiv: UIImageView?
    func testImageDownload() {
        imageDownloadExpectation = self.expectationWithDescription("known image downloaded successfully")

        uiiv = UIImageView()
        tableViewController?.startImageDownload(NSURL(string: correctURL)!, imageView: uiiv!)
        
        imageDownloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("checkForImageDownload"), userInfo: nil, repeats: true)
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    // this is part of testImageDownload()
    func checkForImageDownload() {
        if uiiv!.image != nil {
            imageDownloadTimer?.invalidate()
            imageDownloadExpectation?.fulfill()
        }
    }
    
    func testforceRefreshByPullDown() {
        storyManagerRetrievalExpectation = self.expectationWithDescription("got callback from StoryManager")
        StoryManager.sharedInstance.addListener(self)

        if let tableViewController = tableViewController {
            tableViewController.tableView.scrollRectToVisible(CGRectMake(0, -100, 40, 40), animated: true)
        }
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
        storyManagerRetrievalExpectation = nil
    }
    
    /*
        Additional Test Ideas, not yet implemented
        - navigate to detail view (tableView.didSelectRowAtIndexPath indexPath)
        - navigate back from detail
        - Work offline
        - Sort order
        - addNewsItem
        - archiveNewsItemAtIndex
        - sortAllNewsItems()
        - getNewsItemForTitle
    */
}
