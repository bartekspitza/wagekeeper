//
//  Period.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-03.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class Period {
    static var statsDescriptions = ["Total work-time", "Average shift length", "Total shifts", "Total days worked", "Overtime worked", "Gross money from overtime", "Net money from overtime"]
    
    var shifts = [ShiftModel]()
    var duration = ""
    var netSalary = 0
    var grossSalary: Int = 0
    var workTime: Int = 0
    var shiftsWorked: Int = 0
    var daysWorked: Int = 0
    var durationInOvertime: Int = 0
    var moneyFromOvertime: Int = 0
    var avgShiftLength: Int = 0
    var stats: [String] = [String]()
    
    init(month: [ShiftModel]) {
        self.shifts = month
        
        let tmp = self.salaryInfo()
        
        self.grossSalary = tmp.grossSalary
        self.durationInOvertime = tmp.durationInOvertime
        self.moneyFromOvertime = tmp.moneyEarnedFromOvertime
        self.daysWorked = tmp.daysWorked
        self.workTime = tmp.duration
        self.netSalary = self.getNetSalary()
        self.duration = StringFormatter.durationToString(month: self.shifts)
        
        self.avgShiftLength = self.calculateAvgShiftLength()
        self.shiftsWorked = self.shifts.count
        self.stats = self.makeStats()
    }
    
    func makeStats() -> [String] {
        var ar = [String]()
        
        // Total work-time
        ar.append(StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.workTime)))
        // Avg Shift length
        ar.append(StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.avgShiftLength)))
        // Total shifts worked
        ar.append(String(self.shiftsWorked))
        // Total days worked
        ar.append(String(self.daysWorked))
        // Overtime worked
        ar.append(StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.durationInOvertime)))
        // Money from overtime
        ar.append(StringFormatter.addCurrencyToNumber(amount: self.moneyFromOvertime))
        ar.append(StringFormatter.addCurrencyToNumber(amount: Int(Float(self.moneyFromOvertime) * user.settings.taxRate)))
        return ar
    }
    
    func getNetSalary() -> Int {
        return Int(Float(self.grossSalary) * user.settings.taxRate)
    }
    
    func calculateAvgShiftLength() -> Int {
        return self.workTime/self.shifts.count
    }
    
    func salaryInfo() -> PeriodStats {
        var grossSalary = 0
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
            grossSalary += Int(shiftSalaryInfo.salary)
            minutesInOT += Int(shiftSalaryInfo.overtimeDuration)
            moneyInOT += Int(shiftSalaryInfo.moneyEarnedInOvertime)
            duration += Int(shiftSalaryInfo.duration)
            
            let prevDayComp = calendar.dateComponents([.day], from: shift.date)
            prevDay = prevDayComp.day!
        }
        
        return PeriodStats(salary: grossSalary, duration: duration, OTTime: minutesInOT, moneyFromOT: moneyInOT, daysWorked: daysWorked)
    }
}
