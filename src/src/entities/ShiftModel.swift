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
    
    func salary() -> [Int] {
        var remainingMinutes: Float = 0.0
        var minutesWorked: Float = 0.0
        var minutesInOT: Float = 0.0
        var moneyInOT: Float = 0.0
        var salary: Float = 0.0
        var baseRate: Float = 0.0
        var lunchMinutes: Float = 0.0
        var weekDayInt: Int
        var weekDay: String
        var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var starts = [[Any]]()
        var ends = [[Any]]()
        var rateFields = [myTextField]()
        var starts1 = [[Any]]()
        var ends1 = [[Any]]()
        var rateFields1 = [myTextField]()
        var extendsOver2Days = false
        var shouldSubstractLunch = true
        let calendar = Calendar.current
        var fakeStartingTime = Date(timeIntervalSinceReferenceDate: 0)
        var fakeEndingTime = Date(timeIntervalSinceReferenceDate: 0)
        let fakeStartingTimeComponents = calendar.dateComponents([.hour, .minute], from: self.startingTime)
        fakeStartingTime = calendar.date(byAdding: fakeStartingTimeComponents, to: fakeStartingTime)!
        
        // Computes total minutes in shift
        remainingMinutes = Time.calculateMinutes(from: self.startingTime, to: self.endingTime) //(Float(timeWorked[1])) + (Float(timeWorked[0]) * 60)
        minutesWorked = Time.calculateMinutes(from: self.startingTime, to: self.endingTime)
        
        // Computes day of the week
        let myCalendar = Calendar(identifier: .gregorian)
        weekDayInt = (myCalendar.component(.weekday, from: self.date)) - 1
        weekDay = weekDays[weekDayInt]
        
        // Loads baseRate
        if UserDefaults().string(forKey: "wageRate") != nil {
            baseRate = Float(UserDefaults().string(forKey: "wageRate")!)! / 60
        }
        
        // Loads rules arrays
        let rules1 = UserSettings.OTRulesForDay(day: weekDay)
        starts = rules1[0] as! [[Any]]
        ends = rules1[1] as! [[Any]]
        rateFields = rules1[2] as! [myTextField]
        
        if UserDefaults().string(forKey: "minHours") != nil && UserDefaults().string(forKey: "minHours") != "" {
            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
            if (minimum) >= (minutesWorked) {
                shouldSubstractLunch = false
                minutesWorked = Float(minimum)
                var tempDate: Date
                tempDate = calendar.date(byAdding: .hour, value: Int(minimum/60), to: self.startingTime)!
                
                let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: tempDate)
                fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
                
            } else {
                let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: self.endingTime)
                fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
            }
        } else {
            let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: self.endingTime)
            fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
        }
        
        
        var shiftEnd = Date()
        var shiftStart1 = Date()
        var shiftEnd1 = Date()
        let startOfDay = Date(timeIntervalSinceReferenceDate: 0)
        var endOfDay = Date(timeIntervalSinceReferenceDate: 0)
        var componentsForEndOfDay = DateComponents()
        componentsForEndOfDay.hour = 23
        componentsForEndOfDay.minute = 59
        endOfDay = calendar.date(byAdding: componentsForEndOfDay, to: endOfDay)!
        
        // Loads rules arrays for the next day if the shift extends over 2 days
        if fakeEndingTime < fakeStartingTime {
            extendsOver2Days = true
            let rules2 = UserSettings.OTRulesForDay(day: weekDays[weekDayInt+1])
            starts1 = rules2[0] as! [[Any]]
            ends1 = rules2[1] as! [[Any]]
            rateFields1 = rules2[2] as! [myTextField]
        }
        
        
        let shiftStart = fakeStartingTime
        if extendsOver2Days {
            shiftEnd = endOfDay
            shiftStart1 = startOfDay
            shiftEnd1 = fakeEndingTime
        } else {
            shiftEnd = fakeEndingTime
        }
        
        for i in 0..<starts.count {
            var intervalStart = Date(timeIntervalSinceReferenceDate: 0) // 2001...
            var intervalEnd = Date(timeIntervalSinceReferenceDate: 0) // 2001..
            
            let intervalStartComponents = calendar.dateComponents([.hour, .minute], from: starts[i][1] as! Date)
            let intervalEndComponents = calendar.dateComponents([.hour, .minute], from: ends[i][1] as! Date)
            
            intervalStart = calendar.date(byAdding: intervalStartComponents, to: intervalStart)!
            intervalEnd = calendar.date(byAdding: intervalEndComponents, to: intervalEnd)!
            
            var endTime: Date
            var startTime: Date
            
            if shiftStart > intervalStart {
                if intervalEnd > shiftStart {
                    startTime = shiftStart
                    
                    if intervalEnd >= shiftEnd {
                        endTime = shiftEnd
                    } else {
                        endTime = intervalEnd
                    }
                    
                    let minutesInThisInterval = Time.calculateMinutes(from: startTime, to: endTime)
                    remainingMinutes -= minutesInThisInterval
                    salary += minutesInThisInterval * (Float(Int(rateFields[i].text!)!) / 60)
                }
                
            } else {
                if intervalStart < shiftEnd {
                    startTime = intervalStart
                    if intervalEnd < shiftEnd {
                        endTime = intervalEnd
                    } else {
                        endTime = shiftEnd
                        
                    }
                    
                    let minutesInThisInterval = Time.calculateMinutes(from: startTime, to: endTime)
                    remainingMinutes -= minutesInThisInterval
                    salary += minutesInThisInterval * (Float(Int(rateFields[i].text!)!) / 60)
                }
            }
        }
        if extendsOver2Days {
            for i in 0..<starts1.count {
                var intervalStart = Date(timeIntervalSinceReferenceDate: 0) // 2001...
                var intervalEnd = Date(timeIntervalSinceReferenceDate: 0) // 2001..
                
                let intervalStartComponents = calendar.dateComponents([.hour, .minute], from: starts1[i][1] as! Date)
                let intervalEndComponents = calendar.dateComponents([.hour, .minute], from: ends1[i][1] as! Date)
                
                intervalStart = calendar.date(byAdding: intervalStartComponents, to: intervalStart)!
                intervalEnd = calendar.date(byAdding: intervalEndComponents, to: intervalEnd)!
                
                var endTime: Date
                var startTime: Date
                
                if shiftStart1 > intervalStart {
                    if intervalEnd > shiftStart1 {
                        startTime = shiftStart1
                        
                        if intervalEnd >= shiftEnd1 {
                            endTime = shiftEnd1
                        } else {
                            endTime = intervalEnd
                        }
                        
                        let minutesInThisInterval = Time.calculateMinutes(from: startTime, to: endTime)
                        remainingMinutes -= minutesInThisInterval
                        salary += minutesInThisInterval * (Float(Int(rateFields1[i].text!)!) / 60)
                    }
                    
                } else {
                    if intervalStart < shiftEnd1 {
                        startTime = intervalStart
                        if intervalEnd < shiftEnd1 {
                            endTime = intervalEnd
                        } else {
                            endTime = shiftEnd1
                            
                        }
                        
                        let minutesInThisInterval = Time.calculateMinutes(from: startTime, to: endTime)
                        remainingMinutes -= minutesInThisInterval
                        salary += minutesInThisInterval * (Float(Int(rateFields1[i].text!)!) / 60)
                    }
                }
            }
        }
        moneyInOT = salary
        salary += remainingMinutes * baseRate
        minutesInOT = minutesWorked - remainingMinutes
        
        // Substracts lunchTime with the average money/minute rate
        if shouldSubstractLunch {
            
            lunchMinutes = Float(self.breakTime)
            salary -= (lunchMinutes * (salary/minutesWorked))
            moneyInOT -= (lunchMinutes * (salary/minutesWorked))
        }
        print("asdfasdfsadf")
        print(minutesInOT)
        return [Int(roundf(salary)), Int(minutesInOT), Int(moneyInOT) ]
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
    
    func calcHours() -> [Int] {
        var hoursWorked = 0
        var minutesWorked = 0
        
        let startingHour = Int(String(Array(self.startingTime.description)[11...12]))
        let startingMin = Int(String(Array(self.startingTime.description)[14...15]))
        let endingHour = Int(String(Array(self.endingTime.description)[11...12]))
        let endingMin = Int(String(Array(self.endingTime.description)[14...15]))
        
        if endingHour! - startingHour! > 0 {
            hoursWorked = endingHour! - startingHour!
        } else if endingHour! - startingHour! < 0 {
            hoursWorked = 24 + (endingHour! - startingHour!)
        }
        
        if endingMin! - startingMin! < 0 {
            hoursWorked -= 1
            minutesWorked = 60 - (startingMin! - endingMin!)
        } else if endingMin! - startingMin! > 0 {
            minutesWorked = endingMin! - startingMin!
        }
        
        minutesWorked += (hoursWorked * 60) - self.breakTime
        if UserDefaults().string(forKey: "minHours") != nil {
            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
            if Int(minimum) > minutesWorked {
                minutesWorked = Int(minimum)
            }
        }
        hoursWorked = Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60
        
        return [hoursWorked, minutesWorked]
    }
    
    func durationToString() -> String {
        var totalHours = ""
        let tmp = self.calcHours()
        let hoursWorked = tmp[0]
        let minutesWorked = tmp[1]
        
        if hoursWorked == 0 {
            if minutesWorked == 1 {
                totalHours = "\(minutesWorked)m"
            } else {
                totalHours = "\(minutesWorked)m"
            }
            
        } else if minutesWorked == 0 {
            if hoursWorked == 1 {
                totalHours = "\(hoursWorked)h"
            } else {
                totalHours = "\(hoursWorked)h"
            }
            
        } else {
            if hoursWorked == 1 && minutesWorked != 1 {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            } else if hoursWorked != 1 && minutesWorked == 1 {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            } else if hoursWorked == 1 && minutesWorked == 1 {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            } else {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            }
        }
        
        return totalHours
    }
}
