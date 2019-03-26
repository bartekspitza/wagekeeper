//
//  Overtime.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-22.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseFirestore

class Overtime {
    var days = [OvertimeDay]()
    
    func json() -> [String: Any] {
        var obj = [String: Any]()
        
        for day in days {
            if day.rules.count > 0 {
                obj[day.day] = day.json()
            }
        }
        
        return obj
    }
    
    func isDayDifferent(day: OvertimeDay) -> Bool {
        for x in days {
            if x.equals(another: day) {
                return false
            }
        }
        return true
    }
    
    func getRules(forDay: String) -> OvertimeDay {
        var rules = OvertimeDay(day: forDay, rules: [OvertimeRule]())
        
        for day in days {
            if day.day == forDay {
                rules = day
            }
        }
    
        return rules
    }
    
    func update(day: OvertimeDay) {
        if replaceDay(with: day) == false {
            days.append(day)
        }
    }

    /* Tries to replace a day and returns true if it did, false if it couldn't find a day to replace */
    private func replaceDay(with: OvertimeDay) -> Bool{
        var changed = false
        
        for i in 0..<days.count {
            let day = days[i]
            
            if day.day == with.day {
                days[i] = with
                changed = true
            }
        }
        
        return changed
    }
    
    /* Creates an overtime object from an json object */
    static func createFromData(data: [String: Any]) -> Overtime {
        
        let obj = Overtime()
        
        for i in 0..<7 {
            var rules = [OvertimeRule]()
            
            if let tmp = data[Time.weekDays[i]] {
                
                for rule in tmp as! [[String: Any]] {
                    let starting = (rule["starting"] as! Timestamp).dateValue()
                    let ending = (rule["ending"] as! Timestamp).dateValue()
                    
                    let new = OvertimeRule(starting: starting, ending: ending, rate: rule["rate"] as! Float)
                    rules.append(new)
                }
                
                let day = OvertimeDay(day: Time.weekDays[i], rules: rules)
                obj.days.append(day)
            }
        }
        return obj
    }
}
