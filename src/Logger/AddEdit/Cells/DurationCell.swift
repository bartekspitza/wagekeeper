//
//  DurationCell.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-10.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class DurationCell: UITableViewCell {
    
    @IBOutlet weak var startingField: UITextField!
    @IBOutlet weak var endingField: UITextField!
    @IBOutlet weak var labelBetweenTimes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
