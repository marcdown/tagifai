//
//  TagCell.swift
//  Tagifai
//
//  Created by Marc Brown on 9/29/15.
//  Copyright © 2015 creative mess. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {

    var titleLbl: UILabel?
    var probabilityLbl: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLbl = UILabel()
        self.titleLbl?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.titleLbl!)
        
        self.probabilityLbl = UILabel()
        self.probabilityLbl?.textAlignment = .Right
        self.probabilityLbl?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.probabilityLbl!)
        
        self.setupConstraints()
    }
    
    func setupConstraints() {
        let views = ["titleLbl": self.titleLbl!, "probabilityLbl": self.probabilityLbl!]
        
        // Horizontal
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[titleLbl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[probabilityLbl]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // Vertical
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[titleLbl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[probabilityLbl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
}
