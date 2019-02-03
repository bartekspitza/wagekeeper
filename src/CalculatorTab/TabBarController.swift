//
//  TabBarController.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-23.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

var tabBarHeight: CGFloat?
var shifts = [[Shift]]()
let currencies = ["SEK": "kr",
                  "EUR": "€",
                  "GPD": "£",
                  "NOR": "kr",
                  "USD": "$",
]

let appName = "WageKeeper"
let appBuild = "v1.1"

// Fonts
let fontStandard = UIFont(name: "BarlowSemiCondensed-Regular", size: 19)
let fontDetails = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 13)
let fontNav = UIFont(name: "BarlowSemiCondensed-SemiBold", size: 19)
let fontHeader = UIFont(name: "BarlowSemiCondensed-Regular", size: 11)
let fontStats = UIFont(name: "BarlowSemiCondensed-Regular", size: 16)

let navColor = UIColor(displayP3Red: 0/255, green: 85/255, blue: 100/255, alpha: 1.0)         //TURCOISE THEME
let headerColor = UIColor(displayP3Red: 56/255, green: 135/255, blue: 149/255, alpha: 1.0)    //TURCOISE THEME
//let navColor = UIColor(displayP3Red: 252/255, green: 82/255, blue: 30/255, alpha: 1.0)          //ORANGE THEME
//let headerColor = UIColor(displayP3Red: 253/255, green: 119/255, blue: 35/255, alpha: 1.0)      //ORANGE THEME
let textColor = UIColor.white

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarHeight = self.tabBar.frame.height
        
       
        self.tabBar.tintColor = navColor
        self.tabBar.unselectedItemTintColor = headerColor
        // Do any additional setup after loading the view.
    }

}
