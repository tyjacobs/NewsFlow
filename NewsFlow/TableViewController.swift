//
//  TableViewController.swift
//  FeedEater
//
//  Created by Genius on 7/26/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, StoryListener {

    var items = NSMutableArray()
    var jsondata: NSMutableData = NSMutableData()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a pretty image to the navigation bar
        var navBar: UINavigationBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(named: "WaterTop.png")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forBarMetrics: .Default)

        // register to get notified when the story list is populated or changes
        StoryManager.sharedInstance.addListener(self);
        
        // retrieve all news items - this will invoke storiesChanged() when complete
        StoryManager.sharedInstance.retrieveAllNewsItems();
        
        // TO DO - start progress indicator
    }
        
    func storiesChanged() {
        // TO DO - stop progress indicator
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getImageURL(content: String) -> NSURL? {
        
        var returnURL: NSURL?
        var range: Range<String.Index>? = content.rangeOfString("img src=\"")
        
        if (range != nil) {
            var imagePath = content.substringFromIndex(range!.endIndex) as String
            range = imagePath.rangeOfString("\"")
            if (range != nil) {
                imagePath = "http:" + imagePath.substringToIndex(range!.startIndex)
                returnURL = NSURL(string:imagePath)
            }
        }
        
        return returnURL
    }
    
    func startImageDownload(url: NSURL, imageView: UIImageView){
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                if let img = UIImage(data: data!) {
                    imageView.image = img;
                }
            }
        }
    }

    func getDataFromUrl(url: NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsItem = StoryManager.sharedInstance.allNewsItems[indexPath.row]
        
        let detailController = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as! DetailViewController
        detailController.url = NSURL(string:newsItem.link)!

        self.navigationController?.pushViewController(detailController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StoryManager.sharedInstance.allNewsItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TableViewCell
        
        // two reusable cell templates are used to get the alternating row colors
        if (indexPath.row % 2 == 0) {
            cell = tableView.dequeueReusableCellWithIdentifier("rssItemCell0", forIndexPath: indexPath) as! TableViewCell
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("rssItemCell1", forIndexPath: indexPath) as! TableViewCell
        }

        let newsItem = StoryManager.sharedInstance.allNewsItems[indexPath.row]
        cell.titleLabel!.text = newsItem.title
        cell.subtitleLabel!.text = newsItem.snippet
        
        if let checkedUrl = getImageURL(newsItem.imageURL) {
            startImageDownload(checkedUrl, imageView: cell.customImageView!)
        }
        
        return cell
    }
}
