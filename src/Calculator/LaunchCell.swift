//
//  LaunchCell.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class LaunchCell: UITableViewCell {

    var statsDesc = UILabel()
    var statsInfo = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    func insertStatsDesc(width: CGFloat, text: String) {
        statsDesc.frame = CGRect(x: 0, y: 0, width: Int(width*0.75), height: Int(self.contentView.frame.height))
        statsDesc.center = CGPoint(x: Int((width*0.05) + statsDesc.frame.width/2), y: Int(self.contentView.frame.height/2))
        statsDesc.textColor = UIColor.black.withAlphaComponent(0.9)
        statsDesc.text = text
        statsDesc.font = UIFont.systemFont(ofSize: 14, weight: .light)
        self.contentView.addSubview(statsDesc)
    }
    
    func insertStatsInfo(width: CGFloat, text: String) {
        statsInfo.frame = CGRect(x: 0, y: 0, width: Int((width/2)), height: Int(self.contentView.frame.height))
        statsInfo.center = CGPoint(x: Int((width*0.95) - statsInfo.frame.width/2), y: Int(self.contentView.frame.height/2))
        statsInfo.textColor = UIColor.black.withAlphaComponent(0.9)
        statsInfo.textAlignment = .right
        statsInfo.text = text
        statsInfo.font = UIFont.systemFont(ofSize: 14, weight: .light)
        self.contentView.addSubview(statsInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
