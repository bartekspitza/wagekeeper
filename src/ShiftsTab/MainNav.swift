//
//  MainNav.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-15.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
var navBarHeight: CGFloat?
class MainNav: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.

        navBarHeight = self.navigationBar.frame.height
        self.navigationBar.barTintColor = navColor
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
