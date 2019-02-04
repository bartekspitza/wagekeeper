//
//  Time.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class Time {
    static let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let formatter = DateFormatter()
    static let calendar = Calendar.current
    
    static func dateToDateString(date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: date)
        let dayName = days[calendar.component(.weekday, from: date)-1]
        
        return dayName + ", " + dateString.replacingOccurrences(of: ",", with: "")
    }
    
    static func dateToTimeString(date: Date) -> String {
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let timeString = formatter.string(from: date)
        return timeString
    }
    
    static func combineDateWithTime(date: Date, time: Date) -> Date? {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        
        return calendar.date(from: mergedComponments)
    }
}
