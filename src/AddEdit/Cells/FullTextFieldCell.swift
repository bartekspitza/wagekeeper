//
//  FullTextFieldCell.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-10.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class FullTextFieldCell: UITableViewCell {
    
    @IBOutlet weak var field: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
