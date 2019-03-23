//
//  Settings.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-22.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class Settings {
    var overtime = Overtime()
    var wage: Float = 15.0
    var tax: Float = 20.0
    var currency: String = "USD"
    var title: String = "My job"
    var breakTime: Int = 60
    var startingTime: Date = Time.createDefaultST()
    var endingTime: Date = Time.createDefaultET()
    var newPeriod: Int = 25
    var minimumHours: Int = 0
    
    var taxRate: Float {
        return (100 - tax)/100
    }
    
    var currencySymbol: String {
        return currencies[currency]!
    }
}
