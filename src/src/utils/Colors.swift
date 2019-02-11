//
//  Colors.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-11.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class Colors {
    static public var loggerSectionBG = Colors.get(red: 0, green: 164, blue: 174, alpha: 1)
    
    static func get(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
