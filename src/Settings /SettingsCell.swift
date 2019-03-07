//
//  SettingsCell.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-07.
//  Copyright © 2019 Bartek . All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    var img: UIImageView!
    var field: UITextField!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let image = UIImage(named: "logout");
        img = UIImageView(image: image)
        img.setImageColor(color: UIColor.black.withAlphaComponent(1))
        img.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        img.center = CGPoint(x: 25, y: (self.frame.height)/2)

        field = UITextField()
        field.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        field.frame.origin.x = self.frame.width - 15 - field.frame.width
        field.textAlignment = .right
        
        self.contentView.addSubview(img)
        self.contentView.addSubview(field)
        
        self.indentationLevel = 5
        self.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
