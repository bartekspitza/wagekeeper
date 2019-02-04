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
}
