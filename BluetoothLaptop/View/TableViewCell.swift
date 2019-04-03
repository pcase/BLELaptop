//
//  TableViewCell.swift
//  BluetoothLaptop
//
//  Created by Patty Case on 3/26/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var MACAddress: UILabel!
    @IBOutlet weak var dateAdded: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        imageView?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageView?.clipsToBounds = true
    }
}

