//
//  TableViewCell.swift
//  FeedEater
//
//  Created by Genius on 7/26/15.
//  Copyright (c) 2015 Simple Genius Software. All rights reserved.
//

import UIKit

// this custom table view cell is used for the entries in the main table
class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var customImageView: UIImageView?
    @IBOutlet weak var backgroundImageView: UIImageView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
