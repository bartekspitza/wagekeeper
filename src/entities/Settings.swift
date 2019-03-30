//
//  Settings.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-22.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseFirestore

class Settings {
    var overtime = Overtime()
    var wage: Float = 15.0
    var tax: Float = 20.0
    var title: String = "My job"
    var breakTime: Int = 60
    var startingTime: Date = Time.createDefaultST()
    var endingTime: Date = Time.createDefaultET()
    var newPeriod: Int = 25
    var minimumHours: Int = 0

    var taxRate: Float { return (100 - tax)/100 }

    static func createFromDocumentSnapshot(data: [String: Any]) -> Settings {
        let newSettings = Settings()
        
        if let settings = data["settings"] {
            let tmp = settings as! [String: Any]
            
            if let overtimeData = tmp["overtime"] {
                newSettings.overtime = Overtime.createFromData(data: overtimeData as! [String: Any])
            }
            
            if let wage = tmp["wage"] {
                newSettings.wage = wage as! Float
            }
            
            if let tax = tmp["tax"] {
                newSettings.tax = tax as! Float
            }
            
            if let title = tmp["title"] {
                newSettings.title = title as! String
            }
            
            if let breakTime = tmp["break"] {
                newSettings.breakTime = breakTime as! Int
            }
            
            if let startingTime = tmp["starting"] {
                newSettings.startingTime = (startingTime as! Timestamp).dateValue()
            }
            
            if let endingTime = tmp["ending"] {
                newSettings.endingTime = (endingTime as! Timestamp).dateValue()
            }
            
            if let newPeriod = tmp["newPeriod"] {
                newSettings.newPeriod = newPeriod as! Int
            }
            
            if let minimumHours = tmp["minimumHours"] {
                newSettings.minimumHours = minimumHours as! Int
            }
        }
        return newSettings
    }
    
}
