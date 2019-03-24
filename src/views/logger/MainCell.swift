//
//  Shift cell.swift
//  adding shifts
//
//  Created by Bartek  on 2017-10-26.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var worktime: UILabel!
    @IBOutlet weak var lunch: UILabel!
    @IBOutlet weak var title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.font = UIFont.systemFont(ofSize: 17, weight: .light)
        dateLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        worktime.font = UIFont.systemFont(ofSize: 11, weight: .light)
        lunch.font = UIFont.systemFont(ofSize: 11, weight: .light)
        duration.font = UIFont.systemFont(ofSize: 11, weight: .light)
        
        dateLbl.textColor = Colors.gray
        worktime.textColor = Colors.gray
        lunch.textColor = Colors.gray
        duration.textColor = Colors.gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
