//
//  PeriodStats.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-23.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class PeriodStats {
    var grossSalary: Int
    var duration: Int
    var durationInOvertime: Int
    var moneyEarnedFromOvertime: Int
    var daysWorked: Int
    
    init(salary: Int, duration: Int, OTTime: Int, moneyFromOT: Int, daysWorked: Int) {
        self.grossSalary = salary
        self.duration = duration
        self.durationInOvertime = OTTime
        self.moneyEarnedFromOvertime = moneyFromOT
        self.daysWorked = daysWorked
    }
}
