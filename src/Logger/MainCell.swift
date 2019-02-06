//
//  Shift cell.swift
//  adding shifts
//
//  Created by Bartek  on 2017-10-26.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var accessoryLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lunchLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
