//
//  NewsItem.swift
//  
//
//  Created by Genius on 7/28/15.
//
//

import Foundation
import CoreData

@objc(NewsItem)

class NewsItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var link: String
    @NSManaged var snippet: String
    @NSManaged var imageURL: String
    @NSManaged var dateStamp: NSDate
    @NSManaged var beenViewed: NSNumber
    @NSManaged var archived: NSNumber

}
