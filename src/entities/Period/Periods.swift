//
//  Periods.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-11.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class Periods {
    
    static func makePeriod(yearIndex: Int, monthIndex: Int, successHandler: @escaping () -> ()) {
        DispatchQueue.global().async {
            if periodsSeperatedByYear.count > 0 {
                period = Period(month: periodsSeperatedByYear[yearIndex][monthIndex])
            } else {
                period = nil
            }
            DispatchQueue.main.async {
                successHandler()
            }
            print("Made period for calculation")
        }
    }
    
    static func organizePeriodsByYear(periods: [[Shift]], successHandler: @escaping () -> ()) {
        var ar = [[[Shift]]]()
        
        DispatchQueue.global().async {
            var year = 4000
            for section in periods {
                let decider = Int(String(Array(section[section.count-1].date.description)[0..<4]))
                
                if year == decider! {
                    ar[ar.count-1].append(section)
                } else {
                    ar.append([section])
                    year = decider!
                }
            }
            DispatchQueue.main.async {
                periodsSeperatedByYear = ar
                successHandler()
                print("Organized periods by year")
            }
        }
    }
    
    static func totalShifts() -> Int{
        var total = 0
        
        for period in shifts {
            for _ in period {
                total += 1
            }
        }
        return total
    }
    
    static func insert(shift: Shift) {
        if shifts.isEmpty {
            shifts.append([shift])
        } else {
            shifts[0].append(shift)
        }
    }
    
    static func reOrganize(successHandler: @escaping () -> ()) {
        var tmp = [Shift]()
        
        for period in shifts {
            for shift in period {
                tmp.append(shift)
            }
        }
        
        Periods.organizeShiftsIntoPeriods(ar: tmp, successHandler: successHandler)
        print("Reorganized the shifts array")
    }
    
    static func organizeShiftsIntoPeriods(ar: [Shift], successHandler: @escaping () -> ()) {
        
        DispatchQueue.global().async {
            var new = ar
            new.sort(by: {$0.date > $1.date})
            
            var tempPeriod = [Shift]()
            var organizedPeriods = [[Shift]]()
            
            if user.settings.newPeriod == 0 {
                for i in 0..<new.count {
                    
                    if i == (new.count-1) {
                        tempPeriod.append(new[i])
                        organizedPeriods.append(tempPeriod)
                        
                    } else if new[i].beginsNewPeriod {
                        tempPeriod.append(new[i])
                        organizedPeriods.append(tempPeriod)
                        tempPeriod.removeAll()
                        
                    } else {
                        tempPeriod.append(new[i])
                    }
                }
                
            } else {
                if new.count > 0 {
                    var compare = [4000, 12, 12]
                    let seperator = user.settings.newPeriod
                    
                    for shift in new {
                        let year = Int(String((Array(shift.date.description))[0..<4]))!
                        let month = Int(String((Array(shift.date.description))[5..<7]))!
                        let day = Int(String((Array(shift.date.description))[8..<10]))!
                        
                        
                        if year >= compare[0] && ((month == compare[1] && day >= seperator) || (month == compare[1]+1 && day < seperator) || (month == 1 && compare[1] == 12 && day < seperator))  {
                            organizedPeriods[organizedPeriods.count-1].append(shift)
                            
                        } else {
                            organizedPeriods.append([shift])
                            if day >= seperator {
                                compare = [year, month, seperator]
                            } else {
                                if month - 1 > 0 {
                                    compare = [year, month - 1, seperator]
                                } else {
                                    compare = [year - 1, 12, seperator]
                                }
                            }
                        }
                    }
                }
            }
            shifts = organizedPeriods
            DispatchQueue.main.async {
                successHandler()
            }
        }
    }
}
