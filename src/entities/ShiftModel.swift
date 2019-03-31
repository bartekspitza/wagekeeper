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

class Shift: CustomStringConvertible {
    var title: String
    var date: Date
    var endingTime: Date
    var startingTime: Date
    var breakTime: Int
    var note: String
    var beginsNewPeriod: Bool
    var ID = ""
    
    var description: String {
        return "ID: " + self.ID
    }

    var weekDay: String {
        return self.date.weekday()
    }
    
    var starting: Date {
        return self.startingTime.dateToReferenceButPreserveTime()
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
    }
    
    func computeStats() -> [String: Any] {
        let shiftDuration = self.duration
        var remainingMinutes: Float = Float(shiftDuration.duration/60)
        var money: Float = 0.0
        
        let rules = user.settings.overtime.getRules(forDay: self.weekDay)
        let nextDayRules = user.settings.overtime.getRules(forDay: Time.weekday(afterDay: self.weekDay)).copy()
        nextDayRules.adjustForNextDay()

        for rule in rules.rules + nextDayRules.rules {
            let tmp = rule.intersectionInMinutes(shiftInterval: shiftDuration)
            remainingMinutes -= tmp
            money += rule.rate/60 * tmp
        }

        // Captures overtime stats before we go on and add rest of the duration
        let duration = Float(shiftDuration.duration/60)
        let moneyEarnedInOvertime = money
        let durationInOvertime = duration - remainingMinutes
        
        money += remainingMinutes/60 * user.settings.wage
        
        // subtracts the lunch time based on the average hourly rate in this shift
        if money > 0 {
            money -= Float(self.breakTime) * money/duration
        }
        
        return [
            "salary": money,
            "duration": duration,
            "overtimeDuration": durationInOvertime,
            "moneyEarnedInOvertime": moneyEarnedInOvertime
        ]
    }
    
    var duration: DateInterval {
        var ending = self.adjustedEndingTime()
        let temp = DateInterval(start: self.starting, end: ending)
        
        // Checks for minimum hours setting
        if temp.duration.isLess(than: Double(user.settings.minimumHours*60*60)) {
            ending = Calendar.current.date(byAdding: .hour, value: user.settings.minimumHours, to: self.starting)!
        }
        return DateInterval(start: self.starting, end: ending)
    }
    
    func adjustedEndingTime() -> Date {
        var ending = self.endingTime.dateToReferenceButPreserveTime()
        
        if self.starting > ending {
            ending = Calendar.current.date(byAdding: .day, value: 1, to: ending)!
        }
        return ending
    }
    
    func isEqual(to: Shift) -> Bool{
        
        let isTitleSame = self.title == to.title
        let isDateSame = self.date == to.date
        let isSTSame = self.startingTime == to.startingTime
        let isETSame = self.endingTime == to.endingTime
        let isBreakSame = self.breakTime == to.breakTime
        let isNoteSame = self.note == to.note
        let isBeginsNewPeriodSame = self.beginsNewPeriod == to.beginsNewPeriod
        
        return isTitleSame && isDateSame && isSTSame && isETSame && isBreakSame && isNoteSame && isBeginsNewPeriodSame
    }
}
