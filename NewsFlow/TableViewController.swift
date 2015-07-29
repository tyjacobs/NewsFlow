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
    let activityView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelectionDuringEditing = false;
        
        // add a pretty image to the navigation bar
        var navBar: UINavigationBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(named: "WaterTop.png")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forBarMetrics: .Default)
        
        // install the activity view as the table header, but hide it initially
        self.tableView.tableHeaderView = activityView
        let insets = self.tableView.contentInset;
        let newInsets: UIEdgeInsets = UIEdgeInsetsMake(insets.top - CGFloat(40), insets.left, insets.bottom, insets.right)
        self.tableView.contentInset = newInsets;

        // register to get notified when the story list is populated or changes
        StoryManager.sharedInstance.addListener(self);
        
        reloadStories()
    }
    
    private var reloading = false
    func reloadStories() {
        reloading = true

        // retrieve all news items - this will invoke storiesChanged() when complete
        StoryManager.sharedInstance.retrieveAllNewsItems();
        
        // expose the activity indicator just above the table
        let insets = self.tableView.contentInset;
        let newInsets: UIEdgeInsets = UIEdgeInsetsMake(insets.top + CGFloat(40), insets.left, insets.bottom, insets.right)
        self.tableView.contentInset = newInsets;
        
        activityView.startAnimating()
    }
        
    func storiesChanged() {

        // this is called when the stories are done loading
        // stop and hide the activity indicator above the table and reload the table
        reloading = false
        activityView.stopAnimating()
        
        UIView.animateWithDuration(0.4, animations: {
            let insets = self.tableView.contentInset;
            let newInsets: UIEdgeInsets = UIEdgeInsetsMake(insets.top - CGFloat(40), insets.left, insets.bottom, insets.right)
            self.tableView.contentInset = newInsets;
        })
            
        self.tableView.reloadData()
    }
    
    // this function supports pulling down on the table to initiate a refresh
    private let pullThreshold = -40.0 as CGFloat
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < self.pullThreshold && !reloading {
            // the user has pulled the table view down, which is a gesture to reload
            let yoffset = self.tableView.contentOffset.y
            reloadStories()
        }
    }
    
    // this function supports drilling down into the detail of a story when the user taps on one
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsItem = StoryManager.sharedInstance.allNewsItems[indexPath.row]
        
        let detailController = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as! DetailViewController
        detailController.url = NSURL(string:newsItem.link)!
        
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    // MARK: - Functions related to asynchronous retrieval of images

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
    
    func startImageDownload(url: NSURL, imageView: UIImageView) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    // this is invoked when the user taps "Delete" (after swiping left to reveal the Delete button)
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // we never really delete stories, just mark them Archived and remove them from the list
            StoryManager.sharedInstance.archiveNewsItemAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}
