//
//  InputCell.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-24.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class InputCell: UITableViewCell {
    
    var field1: UITextField!
    var field2: UITextField!
    var textView: UITextView!
    var lbl: UILabel!
    var cellSwitch: UISwitch!
    var view: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.awakeFromNib()
        
        field1 = UITextField()
        field2 = UITextField()
        textView = UITextView()
        lbl = UILabel()
        cellSwitch = UISwitch()
        cellSwitch.isHidden = true
        view = UIView()
        
        self.view.addSubview(lbl)
        self.view.addSubview(cellSwitch)
        self.contentView.addSubview(view)
        self.contentView.addSubview(field1)
        self.contentView.addSubview(field2)
        self.contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
