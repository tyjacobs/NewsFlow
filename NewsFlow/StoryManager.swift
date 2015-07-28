//
//  StoryManager.swift
//  NewsFlow
//
//  Created by Genius on 7/27/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreData
import UIKit

protocol StoryListener {
    func storiesChanged()
}

class StoryManager: NSObject, NSURLConnectionDelegate
{
    static let sharedInstance = StoryManager()
    private override init() {}
    
    static let feedURLString = "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=8&q=http://news.google.com/?output=rss"
    
    private let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    private var listeners: [StoryListener] = []
    private var jsondata: NSMutableData = NSMutableData()
    var allNewsItems: [NewsItem] = []

    
    func addListener(listener: StoryListener) {
        listeners.append(listener)
    }

    func retrieveAllNewsItems()
    {
        // start by retrieving all existing, non-archived news stories from the database and adding those to allNewsItems
        allNewsItems = []
        let fetchRequest = NSFetchRequest(entityName: "NewsItem")
        fetchRequest.predicate = NSPredicate(format: "archived != YES")
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NewsItem] {
            for newsItem in fetchResults {
                allNewsItems.append(newsItem)
            }
        }
        
        if connectedToNetwork()
        {
            // attempt to retrieve stories from the rss feed, store any new stories in database, then notify listeners
            var url: NSURL = NSURL(string:StoryManager.feedURLString)!
            var request: NSURLRequest = NSURLRequest(URL: url)
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        }
        else
        {
            // notify listeners right away since the only stories currently available are the ones from the database
            for listener in listeners {
                listener.storiesChanged()
            }
        }
    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // received a new request, so clear out the json data
        self.jsondata = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // append this chunk of data to the jason data object
        self.jsondata.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // the request is now complete and self.data now holds the full jason data results
        // parse out the entries and save into self.items, then reload the table view
        
        var err: NSError?
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(jsondata, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
        
        if (err == nil) {
            if let responseData = jsonResult["responseData"] as? NSDictionary {
                if let feed = responseData["feed"] as? NSDictionary {
                    if let entries = feed["entries"] as? NSArray {
                        // for each news item retrieved from the rss feed, add it to the database and to allNewsItems
                        // the news items will only actually be added if they are not already in the database, to avoid duplicates
                        for entry in entries {
                            addNewsItem(entry as! NSDictionary)
                        }
                    }
                }
            }
        }
        
        // TO DO before notifying listeners, sort the news items by date
        //self.allNewsItems.sort({ $0.dateStamp > $1.dateStamp })
        
        // notify listeners
        for listener in listeners {
            listener.storiesChanged()
        }
    }

    func addNewsItem(newsItemData: NSDictionary) {
        
        // extract the various parts of the news item
        var title = newsItemData["title"] as! String
        var link = newsItemData["link"] as! String
        var snippet = newsItemData["contentSnippet"] as! String
        var content = newsItemData["content"] as! String
        
        // if this news item is already in the database, then don't add it
        if (getNewsItemForTitle(title) == nil)
        {
            // the news item was not found, so create a new one and add it to the database
            if let entity = NSEntityDescription.entityForName("NewsItem", inManagedObjectContext: self.managedContext)
            {
                let newsItem = NSManagedObject(entity: entity, insertIntoManagedObjectContext:managedContext) as! NewsItem
                
                newsItem.title = title
                newsItem.link = link
                newsItem.snippet = snippet
                newsItem.imageURL = content
                
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                else {
                    // the new item was successfully saved to the database, so add it to the in-memory list
                    allNewsItems.append(newsItem)
                }
            }
        }
    }

    func getNewsItemForTitle(title: String) -> NewsItem? {
        
        // for now, a news item is uniquely identified by its title
        var returnNewsItem: NewsItem?

        if let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        {
            let fetchRequest = NSFetchRequest(entityName: "NewsItem")
            fetchRequest.predicate = NSPredicate(format: "title = %@", title)
            if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NewsItem] {
                if (fetchResults.count > 0) {
                    returnNewsItem = fetchResults[0]
                }
            }
        }
        
        return returnNewsItem
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags : SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}