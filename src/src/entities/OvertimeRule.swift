//
//  OvertimeRule.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-21.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation


class OvertimeRule {
    static var mondayRules = [OvertimeRule]()
    static var tuesdayRules = [OvertimeRule]()
    static var wednesdayRules = [OvertimeRule]()
    static var thursdayRules = [OvertimeRule]()
    static var fridayRules = [OvertimeRule]()
    static var saturdayRules = [OvertimeRule]()
    static var sundayRules = [OvertimeRule]()
    
    var starting: Date!
    var ending: Date!
    var rate: Float!
    var duration: DateInterval!
    
    init(starting: Date, ending: Date, rate: Float) {
        self.starting = starting
        self.ending = ending
        self.rate = rate
        self.duration = getDateInterval()
    }
    
    func getDateInterval() -> DateInterval {
        return DateInterval(start: starting, end: ending)
    }
    
    func intersectionInMinutes(shiftInterval: DateInterval) -> Float {
        var minutes: Float = 0.0
        let duration = shiftInterval.intersection(with: self.duration)
        
        if duration != nil {
            minutes = Float(duration!.duration)/60
        }
        return minutes
    }
    
    static func genRule(from: Int, to: Int, rate: Float) -> OvertimeRule {
        var a = Date(timeIntervalSinceReferenceDate: 0)
        var b = Date(timeIntervalSinceReferenceDate: 0)
        
        a = Calendar.current.date(byAdding: .hour, value: from, to: a)!
        b = Calendar.current.date(byAdding: .hour, value: to, to: b)!
        
        return OvertimeRule(starting: a, ending: b, rate: rate)
    }
    
    func json() -> [String: Any] {
        return [
            "starting": self.starting,
            "ending": self.ending,
            "rate": self.rate
        ]
    }
    
    static func allRulesToJson() -> [String: Any] {
        let obj = [
            "Monday": rulesInDayToJSON(day: OvertimeRule.mondayRules),
            "Tuesday": rulesInDayToJSON(day: OvertimeRule.tuesdayRules),
            "Wednesday": rulesInDayToJSON(day: OvertimeRule.wednesdayRules),
            "Thursday": rulesInDayToJSON(day: OvertimeRule.thursdayRules),
            "Friday": rulesInDayToJSON(day: OvertimeRule.fridayRules),
            "Saturday": rulesInDayToJSON(day: OvertimeRule.saturdayRules),
            "Sunday": rulesInDayToJSON(day: OvertimeRule.sundayRules)
        ]
        
        return obj
    }
    
    private static func rulesInDayToJSON(day: [OvertimeRule]) -> [[String: Any]] {
        var obj = [[String: Any]]()
        
        for rule in day {
            obj.append(rule.json())
        }
        
        return obj
    }
}
