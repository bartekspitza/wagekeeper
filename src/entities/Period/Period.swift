//
//  Period.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-03.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class Period {
    var shifts = [ShiftModel]()
    var duration = ""
    var grossSalary: Int = 0
    var shiftsWorked: Int = 0
    var daysWorked: Int = 0
    var moneyFromOvertime: Int = 0
    
    var workTime: TimeInterval = 0.0
    var durationInOvertime: TimeInterval = 0.0
    
    
    var avgShiftLength: TimeInterval {
        return TimeInterval(self.workTime/Double(self.shifts.count))
    }
    
    var netSalary: Int {
        return Int(Float(self.grossSalary) * user.settings.taxRate)
    }
    
    init(month: [ShiftModel]) {
        self.shifts = month
        
        let tmp = self.salaryInfo()
        self.grossSalary = tmp["salary"] as! Int
        self.durationInOvertime = tmp["overtimeDuration"] as! TimeInterval
        self.moneyFromOvertime = tmp["moneyEarnedInOvertime"] as! Int
        self.daysWorked = tmp["daysWorked"] as! Int
        self.workTime = tmp["duration"] as! TimeInterval
        self.duration = StringFormatter.durationToString(month: self.shifts)
        self.shiftsWorked = self.shifts.count
    }
    
    func salaryInfo() -> [String: Any] {
        var grossSalary: Float = 0.0
        var duration: Float = 0.0
        var minutesInOT: Float = 0.0
        var moneyInOT: Float = 0.0
        var daysWorked = 0
        
        var prevDay = 100
        for shift in self.shifts {
            let calendar = Calendar.current
            let currentDayComp = calendar.dateComponents([.day], from: shift.date)
            let currentDay = currentDayComp.day!
            
            if currentDay != prevDay {
                daysWorked += 1
            }
            let shiftSalaryInfo = shift.computeStats()
            grossSalary += shiftSalaryInfo["salary"] as! Float
            minutesInOT += shiftSalaryInfo["overtimeDuration"] as! Float
            moneyInOT += shiftSalaryInfo["moneyEarnedInOvertime"] as! Float
            duration += shiftSalaryInfo["duration"] as! Float
            
            let prevDayComp = calendar.dateComponents([.day], from: shift.date)
            prevDay = prevDayComp.day!
        }

        return [
            "salary": Int(grossSalary),
            "duration": TimeInterval(duration * 60),
            "overtimeDuration": TimeInterval(minutesInOT * 60),
            "moneyEarnedInOvertime": Int(moneyInOT),
            "daysWorked": daysWorked
        ]
    }
    
    var statsForDisplay: [String] {
        return [
            self.workTime.timeString(),
            self.avgShiftLength.timeString(),
            String(shiftsWorked),
            String(daysWorked),
            self.durationInOvertime.timeString(),
            self.moneyFromOvertime.currencyString(),
            Int(Float(self.moneyFromOvertime) * user.settings.taxRate).currencyString()
        ]
    }
}
