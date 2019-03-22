//
//  ShiftStats.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-21.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class ShiftStats {
    var salary: Float!
    var duration: Float!
    var overtimeDuration: Float!
    var moneyEarnedInOvertime: Float!
    
    init(salary: Float, duration: Float, overtimeDuration: Float, moneyEarnedInOvertime: Float) {
        self.salary = salary
        self.duration = duration
        self.overtimeDuration = overtimeDuration
        self.moneyEarnedInOvertime = moneyEarnedInOvertime
    }
    
    func description() -> String {
        var str = ""
        
        str += "Salary:                     " + self.salary.description + "\n"
        str += "Duration:                   " + self.duration.description + "\n"
        str += "Duration in overtime:       " + self.overtimeDuration.description + "\n"
        str += "Money earned from overtime: " + self.moneyEarnedInOvertime.description
        
        return str
    }
}
