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
import ReachabilitySwift
import Alamofire

// classes interested in being notified when the story list is updated should
// implement this protocol and register as a listener on StoryManager.sharedInstance
public protocol StoryListener {
    func storiesChanged()
    func networkConnected()
}

// this singleton class manages the list of cached and dynamically retrieved news items
// use StoryManager.sharedInstance, call addListener(), and then retrieveAllNewsItems()
public class StoryManager: NSObject, NSURLConnectionDelegate {

    public static let sharedInstance = StoryManager()

    static let feedURLString = "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=8&q=http://news.google.com/?output=rss"
    
    private var reachability: Reachability?
    public var connectedToNetwork = false
    
    private let managedContext = CoreDataManager.sharedManager.managedObjectContext!
    private var listeners: [StoryListener] = []
    private var reloading = false
    var allNewsItems: [NewsItem] = []
    
    private override init() {
        
        super.init()

        reachability = try? startReachability()
        if reachability == nil {
            // there was some problem setting up reachability (startReachability() threw an exception)
            // but in this case connectedToNetwork will still have the default value of false, so
            // from the user's perspective, it just means that the network is not available.  Generally
            // this should "never" happen and there is no good way to explain it to the user anyway,
            // so, do nothing.
        }
    }
    
    deinit {
        stopReachability()
    }
    
    public func addListener(listener: StoryListener) {

        listeners.append(listener)
    }

    public func retrieveAllNewsItems() {

        // prevent the retrieval from running multiple times in parallel
        if reloading { return }
        reloading = true

        // start by retrieving all existing, non-archived news stories from the database and adding those to allNewsItems
        allNewsItems = []
        let fetchRequest = NSFetchRequest(entityName: "NewsItem")
        fetchRequest.predicate = NSPredicate(format: "archived != YES")
        if let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NewsItem] {
            for newsItem in fetchResults {
                allNewsItems.append(newsItem)
            }
        }
        
        // now attempt to retrieve stories from the rss feed, store any new stories in database, then notify listeners
        if connectedToNetwork {
            
            Alamofire.request(.GET, StoryManager.feedURLString).responseJSON { response in
            
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if let jsonResult = response.result.value {
                    //print("JSON: \(jsonResult)")
                    
                    if let responseData = jsonResult["responseData"] as? NSDictionary {
                        if let feed = responseData["feed"] as? NSDictionary {
                            if let entries = feed["entries"] as? NSArray {
                                // for each news item retrieved from the rss feed, add it to the database and to allNewsItems
                                // the news items will only actually be added if they are not already in the database, to avoid duplicates
                                for entry in entries {
                                    self.addNewsItem(entry as! NSDictionary)
                                }
                            }
                        }
                    }
                }
                
                self.sortAndNotifyListeners()
                self.reloading = false
            }
        }
        else {
            
            // notify listeners right away since the only stories currently available are the ones from the database
            sortAndNotifyListeners()
            reloading = false
        }
    }
    
    func sortAndNotifyListeners() {
        
        self.sortAllNewsItems()
        
        // notify listeners
        for listener in self.listeners {
            listener.storiesChanged()
        }
    }
    
    // add a new news item to the database (and cached list), if it does not already exist
    func addNewsItem(newsItemData: NSDictionary) {
        
        // extract the various parts of the news item
        let title = newsItemData["title"] as! String
        let link = newsItemData["link"] as! String
        let snippet = newsItemData["contentSnippet"] as! String
        let content = newsItemData["content"] as! String
        let publishedDateString = newsItemData["publishedDate"] as! String
        
        // example of format: Tue, 28 Jul 2015 14:33:35 -0700
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss z"

        let publishedDate = dateFormatter.dateFromString(publishedDateString)
        
        // if this news item is already in the database, then don't add it
        if getNewsItemForTitle(title) == nil {
            // the news item was not found, so create a new one and add it to the database
            if let entity = NSEntityDescription.entityForName("NewsItem", inManagedObjectContext: self.managedContext) {
                
                let newsItem = NSManagedObject(entity: entity, insertIntoManagedObjectContext:managedContext) as! NewsItem
                
                newsItem.title = title
                newsItem.link = link
                newsItem.snippet = snippet
                newsItem.imageURL = content
                newsItem.dateStamp = publishedDate!
                
                var error: NSError?
                do {
                    try managedContext.save()
                    // the new item was successfully saved to the database, so add it to the in-memory list
                    allNewsItems.append(newsItem)
                } catch let error1 as NSError {
                    error = error1
                    print("Could not save \(error), \(error?.userInfo)")
                }
            }
        }
    }
    
    // delete the news item at the given index
    // listeners are not notified, so the caller is responsible for updating its local state surgically or otherwise reloading
    func archiveNewsItemAtIndex(indexOfItemToArchive: Int) {
        let newsItemToDelete = allNewsItems[indexOfItemToArchive]
        allNewsItems.removeAtIndex(indexOfItemToArchive)
        
        newsItemToDelete.archived = true
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func sortAllNewsItems() {
        self.allNewsItems.sortInPlace({ $0.dateStamp.compare($1.dateStamp) == NSComparisonResult.OrderedDescending })
    }

    // return the matching news item, or nil if it does not exist
    func getNewsItemForTitle(title: String) -> NewsItem? {
        
        // for now, a news item is uniquely identified by its title
        var returnNewsItem: NewsItem?

        if let managedContext = CoreDataManager.sharedManager.managedObjectContext {
            
            let fetchRequest = NSFetchRequest(entityName: "NewsItem")
            fetchRequest.predicate = NSPredicate(format: "title = %@", title)
            if let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NewsItem] {
                if fetchResults.count > 0 {
                    returnNewsItem = fetchResults[0]
                }
            }
        }
        
        return returnNewsItem
    }
}

// Reachability stuff
extension StoryManager {
    
    func startReachability() throws -> Reachability {
        
        let reachability = try Reachability.reachabilityForInternetConnection()
        
        reachability.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.connectedToNetwork = true
                
                for listener in self.listeners {
                    listener.networkConnected()
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.connectedToNetwork = false
            }
        }
        
        try reachability.startNotifier()
        
        return reachability
    }
    
    func stopReachability() {
        reachability?.stopNotifier()
    }
}