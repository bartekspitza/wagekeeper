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
    var workTime: Int = 0
    var shiftsWorked: Int = 0
    var daysWorked: Int = 0
    var durationInOvertime: Int = 0
    var moneyFromOvertime: Int = 0
    
    var avgShiftLength: Int {
        return self.workTime/self.shifts.count
    }
    
    var netSalary: Int {
        return Int(Float(self.grossSalary) * user.settings.taxRate)
    }
    
    init(month: [ShiftModel]) {
        self.shifts = month
        
        let tmp = self.salaryInfo()
        self.grossSalary = tmp["salary"]!
        self.durationInOvertime = tmp["overtimeDuration"]!
        self.moneyFromOvertime = tmp["moneyEarnedInOvertime"]!
        self.daysWorked = tmp["daysWorked"]!
        self.workTime = tmp["duration"]!
        self.duration = StringFormatter.durationToString(month: self.shifts)
        self.shiftsWorked = self.shifts.count
    }
    
    func salaryInfo() -> [String: Int] {
        var grossSalary: Float = 0.0
        var duration = 0
        var minutesInOT = 0
        var moneyInOT = 0
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
            minutesInOT += Int(shiftSalaryInfo["overtimeDuration"] as! Float)
            moneyInOT += Int(shiftSalaryInfo["moneyEarnedInOvertime"] as! Float)
            duration += Int(shiftSalaryInfo["duration"] as! Float)
            
            let prevDayComp = calendar.dateComponents([.day], from: shift.date)
            prevDay = prevDayComp.day!
        }

        return [
            "salary": Int(grossSalary),
            "duration": duration,
            "overtimeDuration": minutesInOT,
            "moneyEarnedInOvertime": moneyInOT,
            "daysWorked": daysWorked
        ]
    }
    
    var statsForDisplay: [String] {
        return [
            StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.workTime)),
            StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.avgShiftLength)),
            String(shiftsWorked),
            String(daysWorked),
            StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.durationInOvertime)),
            StringFormatter.addCurrencyToNumber(amount: self.moneyFromOvertime),
            StringFormatter.addCurrencyToNumber(amount: Int(Float(self.moneyFromOvertime) * user.settings.taxRate))
        ]
    }
}
