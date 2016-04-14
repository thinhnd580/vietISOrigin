//
//  DirectionCell.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/8/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit

class DirectionCell: UITableViewCell {
    
    @IBOutlet weak var imgDot: UIButton!
    @IBOutlet weak var lbAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgDot.clipsToBounds = true
        self.imgDot.layer.cornerRadius = 10
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
