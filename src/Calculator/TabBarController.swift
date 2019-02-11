//
//  TabBarController.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-23.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

var tabBarHeight: CGFloat?
let currencies = ["SEK": "kr",
                  "EUR": "€",
                  "GPD": "£",
                  "NOR": "kr",
                  "USD": "$",
]



let navColor = UIColor(displayP3Red: 0/255, green: 85/255, blue: 100/255, alpha: 1.0)         //TURCOISE THEME
let headerColor = UIColor(displayP3Red: 56/255, green: 135/255, blue: 149/255, alpha: 1.0)    //TURCOISE THEME
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
