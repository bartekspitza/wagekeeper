//
//  StringFormatter.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class StringFormatter {
    
    static func durationToString(month: [Shift]) -> String {
        var date = ""
        
        let firstDate = String(Array(Time.dateToString(date: month[0].date, withDayName: false))[0..<Time.dateToString(date: month[0].date, withDayName: false).count-5])
        let secondDate = String(Array(Time.dateToString(date: (month.last?.date)!, withDayName: false))[0..<Time.dateToString(date: (month.last?.date)!, withDayName: false).count-5])
        date = secondDate + " - " + firstDate
        
        return date
    }
}
