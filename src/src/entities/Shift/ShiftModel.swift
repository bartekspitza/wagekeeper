//
//  ShiftModel.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ShiftModel: CustomStringConvertible {
    var title: String
    var date: Date
    var endingTime: Date
    var startingTime: Date
    var breakTime: Int
    var note: String
    var beginsNewPeriod: Bool
    var ID = ""
    var duration: DateInterval
    
    public var description: String {
        return "ID: " + self.ID
    }
    
    init(title: String, date: Date, startingTime: Date, endingTime: Date, breakTime: Int, note: String, newPeriod: Bool, ID: String) {
        self.title = title
        self.date = date
        self.startingTime = startingTime
        self.endingTime = endingTime
        self.breakTime = breakTime
        self.note = note
        self.beginsNewPeriod = newPeriod
        self.ID = ID
        self.duration = DateInterval(start: startingTime, end: endingTime)
        
        // if shift extends to next day we need to adjust the ending date
        if self.startingTime > self.endingTime {
            self.endingTime = Calendar.current.date(byAdding: .day, value: 1, to: self.endingTime)!
        }
    }
    
    private func getDuration() -> DateInterval{
        var ending = self.endingTime
        
        // Checks for minimum hours setting
        if self.duration.duration.isLess(than: Double(UserSettings.getMinHours()*60*60)) {
            ending = Calendar.current.date(byAdding: .hour, value: UserSettings.getMinHours(), to: startingTime)!
        }
        return DateInterval(start: self.startingTime, end: ending)
        
    }
    
    func computeStats() -> ShiftStats {
        let shiftDuration = self.getDuration()
        var remainingMinutes: Float = Float(shiftDuration.duration/60)
        var money: Float = 0.0
//        let rules = [OvertimeRule.genRule(from: 4, to: 6, rate: 120)]
//        
//        for rule in rules {
//            let minutesInRule = rule.intersectionInMinutes(shiftInterval: shiftDuration)
//            money += rule.rate! * minutesInRule/60
//            remainingMinutes -= minutesInRule
//        }
        
        // Captures overtime stats before we go on and add rest of the duration
        let duration = Float(shiftDuration.duration/60)
        let moneyEarnedInOvertime = money
        let durationInOvertime = duration - remainingMinutes
        
        money += remainingMinutes/60 * UserSettings.getWage()
        
        // subtracts the lunch time based on the average hourly rate in this shift
        money -= Float(self.breakTime) * money/duration
        
        return ShiftStats(
            salary: money,
            duration: duration,
            overtimeDuration: durationInOvertime,
            moneyEarnedInOvertime: moneyEarnedInOvertime
        )
    }
    
    func isEqual(to: ShiftModel) -> Bool{
        
        let isTitleSame = self.title == to.title
        let isDateSame = self.date == to.date
        let isSTSame = self.startingTime == to.startingTime
        let isETSame = self.endingTime == to.endingTime
        let isBreakSame = self.breakTime == to.breakTime
        let isNoteSame = self.note == to.note
        let isBeginsNewPeriodSame = self.beginsNewPeriod == to.beginsNewPeriod
        
        return isTitleSame && isDateSame && isSTSame && isETSame && isBreakSame && isNoteSame && isBeginsNewPeriodSame
    }
    
    static func createFromCoreData(s: Shift) -> ShiftModel {
        let breakTime = (s.lunchTime == "") ? 0 : Int(s.lunchTime!)!
        let newMonth = s.newMonth == Int16(1)
        
        return ShiftModel(title: s.note!, date: s.date!, startingTime: s.startingTime!, endingTime: s.endingTime!,  breakTime: breakTime, note: "", newPeriod: newMonth, ID: "")
    }
    
    
    
    func toCoreData() -> Shift {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shift = Shift(context: context)
        shift.date = self.date
        shift.endingTime = self.endingTime
        shift.startingTime = self.startingTime
        shift.lunchTime = String(self.breakTime)
        shift.note = self.title
        shift.newMonth = (self.beginsNewPeriod) ? Int16(1) : Int16(0)
        
        return shift
    }
    
    
//    func durationToString() -> String {
//        var totalHours = ""
//        let tmp = self.calcHours()
//        let hoursWorked = tmp[0]
//        let minutesWorked = tmp[1]
//        
//        if hoursWorked == 0 {
//            if minutesWorked == 1 {
//                totalHours = "\(minutesWorked)m"
//            } else {
//                totalHours = "\(minutesWorked)m"
//            }
//            
//        } else if minutesWorked == 0 {
//            if hoursWorked == 1 {
//                totalHours = "\(hoursWorked)h"
//            } else {
//                totalHours = "\(hoursWorked)h"
//            }
//            
//        } else {
//            if hoursWorked == 1 && minutesWorked != 1 {
//                totalHours = "\(hoursWorked)h \(minutesWorked)m"
//            } else if hoursWorked != 1 && minutesWorked == 1 {
//                totalHours = "\(hoursWorked)h \(minutesWorked)m"
//            } else if hoursWorked == 1 && minutesWorked == 1 {
//                totalHours = "\(hoursWorked)h \(minutesWorked)m"
//            } else {
//                totalHours = "\(hoursWorked)h \(minutesWorked)m"
//            }
//        }
//        
//        return totalHours
//    }
}
