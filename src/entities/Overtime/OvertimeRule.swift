//
//  OvertimeRule.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-03-21.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseFirestore

class OvertimeRule {
    var starting: Date!
    var ending: Date!
    var rate: Float!
    
    var duration: DateInterval {
        return DateInterval(start: starting, end: ending)
    }
    
    init(starting: Date, ending: Date, rate: Float) {
        self.starting = starting
        self.ending = ending
        self.rate = rate
    }
    
    func intersectionInMinutes(shiftInterval: DateInterval) -> Float {
        var minutes: Float = 0.0
        let duration = shiftInterval.intersection(with: self.duration)
        
        if duration != nil {
            minutes = Float(duration!.duration)/60
        }
        return minutes
    }
    
    func json() -> [String: Any] {
        return [
            "starting": self.starting,
            "ending": self.ending,
            "rate": self.rate
        ]
    }
    
    func copy() -> OvertimeRule {
        return OvertimeRule(starting: starting, ending: ending, rate: rate)
    }
    
    func equals(another: OvertimeRule) -> Bool {
        let startIsSame = starting.description == another.starting.description
        let endingIsSame = ending.description == another.ending.description
        let rateIsSame = rate == another.rate
        
        return startIsSame && endingIsSame && rateIsSame
    }
}
