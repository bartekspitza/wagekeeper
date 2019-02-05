//
//  StringFormatter.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class StringFormatter {
    
    static func addCurrencyToNumber(amount: Int) -> String {
        let symbol = UserSettings.getCurrencySymbol()
        if symbol == "kr" {
            return amount.description + "kr"
        } else {
            return symbol + amount.description
        }
    }
    
    static func stringFromHoursAndMinutes(a: [Int]) -> String {
        var str = ""
        let hours = a[0]
        let minutes = a[1]
        
        if minutes == 0 {
            str = String(hours) + "H"
        } else {
            str = "\(hours)H \(minutes)M"
        }
        return str
    }
    
    static func durationToString(month: [ShiftModel]) -> String {
        var date = ""
        
        let firstDate = String(Array(Time.dateToString(date: month[0].date, withDayName: false))[0..<Time.dateToString(date: month[0].date, withDayName: false).count-5])
        let secondDate = String(Array(Time.dateToString(date: (month.last?.date)!, withDayName: false))[0..<Time.dateToString(date: (month.last?.date)!, withDayName: false).count-5])
        date = secondDate + " - " + firstDate
        
        return date
    }
}
