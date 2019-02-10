//
//  UserSettings.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class UserSettings {
    
    static func OTRulesForDay(day: String) -> [Any] {
        if UserDefaults().value(forKey: day) != nil {
            let instanceEncoded: [NSData] = UserDefaults().object(forKey: day) as! [NSData]
            let startsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[0] as Data)
            let endsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[1] as Data)
            let rateFieldsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[2] as Data)
            
            return [startsUnpacked!, endsUnpacked!, rateFieldsUnpacked!]
        } else {
            return [[], [], []]
        }
    }
    
    static func getCurrencySymbol() -> String {
        var symbol = ""
        if UserDefaults().string(forKey: "currency") != nil && UserDefaults().string(forKey: "currency") != "" {
            symbol = currencies[UserDefaults().string(forKey: "currency")!]!
        }
        return symbol
    }
    
    static func taxRate() -> Float {
        var taxRate: Float = 1.0
        if UserDefaults().string(forKey: "baseTaxRate") != nil {
            taxRate -= Float(UserDefaults().string(forKey: "baseTaxRate")!)! / 100
        }
        return taxRate
    }
    
    static func initiateUserDefaults() {
        UserDefaults().set("0.0", forKey: "taxRate")
        UserDefaults().set("10", forKey: "wageRate")
        UserDefaults().set("USD", forKey: "currency")
        UserDefaults().set(false, forKey: "manuallyNewMonth")
        UserDefaults().set("1", forKey: "newMonth")
        UserDefaults().set("0", forKey: "minHours")
        UserDefaults().set(Time.createDefaultST(), forKey: "defaultST")
        UserDefaults().set(Time.createDefaultET(), forKey: "defaultET")
        UserDefaults().set("Example (Delete this)", forKey: "defaultNote")
        UserDefaults().set("0", forKey: "defaultLunch")
    }
    
    static func getDefaultShiftName() -> String {
        var s = ""
        if UserDefaults().string(forKey: "defaultNote") != nil {
            s = UserDefaults().string(forKey: "defaultNote")!
        }
        return s
    }
    
    static func getDefaultStartingTime() -> Date {
        var s = Date()
        if UserDefaults().value(forKey: "defaultST") != nil {
            s = UserDefaults().value(forKey: "defaultST") as! Date
        }
        return s
    }
    
    static func getDefaultEndingTime() -> Date {
        var s = Date()
        if UserDefaults().value(forKey: "defaultET") != nil {
            s = UserDefaults().value(forKey: "defaultET") as! Date
        }
        return s
    }
    
    static func getDefaultBreakTime() -> String {
        var s = ""
        if UserDefaults().value(forKey: "defaultLunch") != nil {
            s = UserDefaults().string(forKey: "defaultLunch")!
        }
        return s
    }
}
