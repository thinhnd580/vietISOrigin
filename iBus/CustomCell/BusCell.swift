//
//  BusCell.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/8/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit

class BusCell: UITableViewCell {

    @IBOutlet weak var lbBusTrip: UILabel!
    @IBOutlet weak var lbBusNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lbBusNumber.layer.cornerRadius = 5
        self.lbBusNumber.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
