//
//  UserSettings.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class UserSettings {
    
    static func setupNewUser() {
        if UserDefaults().value(forKey: "FirstTime") == nil {
            UserSettings.initiateUserDefaults()
            UserDefaults().set("Visited", forKey: "FirstTime")
        }
    }
    
    static func setEmail(email: String?) {
        UserDefaults().set(email, forKey: "email")
    }
    
    static func getEmail() -> String? {
        return UserDefaults().string(forKey: "email")
    }
    
    static func getMinHours() -> Int {
        var s = Int.max
        
        if UserDefaults().string(forKey: "minHours") != nil && UserDefaults().string(forKey: "minHours") != "" {
            s = UserDefaults().integer(forKey: "minHours")
        }
        
        return s
    }
    static func OTRulesForDay(day: String) -> [Any] {
        var startsUnpacked: Any?
        var endsUnpacked: Any?
        var rateFieldsUnpacked: Any?
        DispatchQueue.main.sync {
            if UserDefaults().value(forKey: day) != nil {
                let instanceEncoded: [NSData] = UserDefaults().object(forKey: day) as! [NSData]
                startsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[0] as Data)
                endsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[1] as Data)
                rateFieldsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[2] as Data)
            }
        }
        
        if startsUnpacked != nil {
            return [startsUnpacked!, endsUnpacked!, rateFieldsUnpacked!]
        }
        return [[], [], []]
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
        if UserDefaults().string(forKey: "taxRate") != nil {
            taxRate -= Float(UserDefaults().string(forKey: "taxRate")!)! / 100
        }
        return taxRate
    }
    
    static func initiateUserDefaults() {
        UserDefaults().set("0.0", forKey: "taxRate")
        UserDefaults().set("10", forKey: "wageRate")
        UserDefaults().set("USD", forKey: "currency")
        UserDefaults().set(true, forKey: "manuallyNewMonth")
        UserDefaults().set("1", forKey: "newMonth")
        UserDefaults().set("0", forKey: "minHours")
        UserDefaults().set(Time.createDefaultST(), forKey: "defaultST")
        UserDefaults().set(Time.createDefaultET(), forKey: "defaultET")
        UserDefaults().set("My job", forKey: "defaultNote")
        UserDefaults().set("60", forKey: "defaultLunch")
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
    
    static func getWage() -> Float {
        var s: Float = 0.0
        if UserDefaults().string(forKey: "wageRate") != nil {
            s = UserDefaults().float(forKey: "wageRate")
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
    
    static func newPeriodsManually() -> Bool {
        return UserDefaults().bool(forKey: "manuallyNewMonth")
    }
}
