//
//  Period.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-03.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class Period {
    static var statsDescriptions = ["TOTAL WORK-TIME", "AVERAGE SHIFT LENGTH", "TOTAL SHIFTS", "TOTAL DAYS WORKED", "OVERTIME WORKED"]
    
    var shifts = [ShiftModel]()
    var duration = ""
    var salary = 0
    var grossSalary: Int = 0
    var amountHoursMinutesWorked: [Int] = [0,0]
    var shiftsWorked: Int = 0
    var daysWorked: Int = 0
    var minutesInOvertime: Int = 0
    var moneyFromOvertime: Int = 0
    var avgShift: [Int] = [0,0]
    var stats: [String] = [String]()
    
    
    init(month: [ShiftModel]) {
        self.shifts = month
        
        let salaryInfo = self.salaryInfo()
        
        self.grossSalary = salaryInfo[0]
        self.minutesInOvertime = salaryInfo[1]
        self.moneyFromOvertime = salaryInfo[2]
        self.daysWorked = salaryInfo[3]
        self.salary = self.netSalary()
        self.duration = StringFormatter.durationToString(month: self.shifts)
        self.amountHoursMinutesWorked = self.calculateHoursMinutesWorked()
        self.avgShift = self.calculateAvgShiftLength()
        self.shiftsWorked = self.shifts.count
        self.stats = self.makeStats()
    }
    
    func makeStats() -> [String] {
        var ar = [String]()
        
        // Total work-time
        ar.append(StringFormatter.stringFromHoursAndMinutes(a: self.amountHoursMinutesWorked))
        // Avg Shift length
        ar.append(StringFormatter.stringFromHoursAndMinutes(a: self.avgShift))
        // Total shifts worked
        ar.append(String(self.shiftsWorked))
        // Total days worked
        ar.append(String(self.daysWorked))
        // Overtime worked
        ar.append(StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: self.minutesInOvertime)))
        // Money from overtime
        ar.append(StringFormatter.addCurrencyToNumber(amount: self.moneyFromOvertime))
        return ar
    }
    
    func netSalary() -> Int {
        return Int(Float(self.grossSalary) * UserSettings.taxRate())
    }
    
    func calculateAvgShiftLength() -> [Int] {
        var hoursWorked = self.amountHoursMinutesWorked[0]
        var minutesWorked = self.amountHoursMinutesWorked[1]
        
        minutesWorked += hoursWorked * 60
        
        minutesWorked /= self.shifts.count
        
        hoursWorked = Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60
        
        return [hoursWorked, minutesWorked]
    }
    
    func calculateHoursMinutesWorked() -> [Int] {
        var hoursWorked = 0
        var minutesWorked = 0
        
        for day in self.shifts {
            let tmp = day.calcHours()
            hoursWorked += tmp[0]
            minutesWorked += tmp[1]
        }
        
        hoursWorked += Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60
        
        
        return [hoursWorked, minutesWorked]
    }
    
    func salaryInfo() -> [Int] {
        var grossSalary = 0
        var minutesInOT = 0
        var moneyInOT = 0
        var daysWorked = 0
        
        // Computes month gross salary
        var prevDay = 100
        for shift in self.shifts {
            let calendar = Calendar.current
            let currentDayComp = calendar.dateComponents([.day], from: shift.date)
            let currentDay = currentDayComp.day!
            
            if currentDay != prevDay {
                daysWorked += 1
            }
            let shiftSalaryInfo = shift.salary()
            grossSalary += shiftSalaryInfo[0]
            minutesInOT += shiftSalaryInfo[1]
            moneyInOT += shiftSalaryInfo[2]
            let prevDayComp = calendar.dateComponents([.day], from: shift.date)
            prevDay = prevDayComp.day!
        }
        
        return [grossSalary, minutesInOT, moneyInOT, daysWorked]
    }
    
    static func convertShiftsFromCoreDataToModels(arr: [[Shift]]) -> [[ShiftModel]] {
        var ar = [[ShiftModel]]()
        
        for period in arr {
            var tmp = [ShiftModel]()
            for a in period {
                tmp.append(ShiftModel.createFromCoreData(s: a))
            }
            ar.append(tmp)
        }
        
        return ar
    }
    
    static func organizeShiftsIntoPeriods(ar: inout [Shift]) -> [[Shift]]{
        ar.sort(by: {$0.date! > $1.date!})
        
        var tempPeriod = [Shift]()
        var organizedPeriods = [[Shift]]()
        
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            for i in 0..<ar.count {
                
                if i == (ar.count-1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    
                } else if ar[i].newMonth == Int16(1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    tempPeriod.removeAll()
                    
                } else {
                    tempPeriod.append(ar[i])
                }
            }
            
        } else {
            if ar.count > 0 {
                var compare = [4000, 12, 12]
                let seperator = Int(UserDefaults().string(forKey: "newMonth")!)!
                
                for shift in ar {
                    let year = Int(String((Array(shift.date!.description))[0..<4]))!
                    let month = Int(String((Array(shift.date!.description))[5..<7]))!
                    let day = Int(String((Array(shift.date!.description))[8..<10]))!
                    
                    
                    if year >= compare[0] && ((month == compare[1] && day >= seperator) || (month == compare[1]+1 && day < seperator) || (month == 1 && compare[1] == 12 && day < seperator))  {
                        organizedPeriods[organizedPeriods.count-1].append(shift)
                        
                    } else {
                        organizedPeriods.append([shift])
                        if day >= seperator {
                            compare = [year, month, seperator]
                        } else {
                            if month - 1 > 0 {
                                compare = [year, month - 1, seperator]
                            } else {
                                compare = [year - 1, 12, seperator]
                            }
                        }
                    }
                }
            }
        }
        return organizedPeriods
    }
    
    static func organizeShiftsIntoPeriods(ar: inout [ShiftModel]) -> [[ShiftModel]]{
        ar.sort(by: {$0.date > $1.date})
        
        var tempPeriod = [ShiftModel]()
        var organizedPeriods = [[ShiftModel]]()
        
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            for i in 0..<ar.count {
                
                if i == (ar.count-1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    
                } else if ar[i].beginsNewPeriod == Int16(1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    tempPeriod.removeAll()
                    
                } else {
                    tempPeriod.append(ar[i])
                }
            }
            
        } else {
            if ar.count > 0 {
                var compare = [4000, 12, 12]
                let seperator = Int(UserDefaults().string(forKey: "newMonth")!)!
                
                for shift in ar {
                    let year = Int(String((Array(shift.date.description))[0..<4]))!
                    let month = Int(String((Array(shift.date.description))[5..<7]))!
                    let day = Int(String((Array(shift.date.description))[8..<10]))!
                    
                    
                    if year >= compare[0] && ((month == compare[1] && day >= seperator) || (month == compare[1]+1 && day < seperator) || (month == 1 && compare[1] == 12 && day < seperator))  {
                        organizedPeriods[organizedPeriods.count-1].append(shift)
                        
                    } else {
                        organizedPeriods.append([shift])
                        if day >= seperator {
                            compare = [year, month, seperator]
                        } else {
                            if month - 1 > 0 {
                                compare = [year, month - 1, seperator]
                            } else {
                                compare = [year - 1, 12, seperator]
                            }
                        }
                    }
                }
            }
        }
        return organizedPeriods
    }
}
