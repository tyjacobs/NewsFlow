//
//  StoryTableViewCell.swift
//  FeedEater
//
//  Created by Genius on 7/26/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import UIKit

// this custom table view cell is used for the entries in the main story table
class StoryTableViewCell: UITableViewCell {
    
    static let defaultStoryImage = UIImage(named: "ImagePlaceholder160.png")!
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var customImageView: UIImageView?
    @IBOutlet weak var backgroundImageView: UIImageView?
    
    var newsItem: NewsItem? {
        didSet {
            self.titleLabel?.text = self.newsItem?.title
            self.subtitleLabel?.text = self.newsItem?.snippet
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setStoryImage(storyImage: UIImage?) {
        
        if let storyImage = storyImage {
            self.customImageView?.image = storyImage
        }
        else {
            self.customImageView?.image = StoryTableViewCell.defaultStoryImage
        }
    }
}
