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
    
    static func insert(shift: ShiftModel) {
        if shifts.isEmpty {
            shifts.append([shift])
        } else {
            shifts[0].append(shift)
        }
    }
    
    static func reOrganize() {
        var tmp = [ShiftModel]()
        
        for period in shifts {
            for shift in period {
                tmp.append(shift)
            }
        }
        
        shifts = Periods.organizeShiftsIntoPeriods(ar: &tmp)
    }
    
    static func convertShiftsFromCoreDataToModels(arr: [[Shift]]) -> [[ShiftModel]] {
        var ar = [[ShiftModel]]()
        
        for period in arr {
            var tmp = [ShiftModel]()
            for a in period {
                tmp.append(ShiftModel.createFromCoreData(s: a))
            }
            ar.append(tmp)
        }
        
        return ar
    }
    
    static func organizeShiftsIntoPeriods(ar: inout [Shift]) -> [[Shift]]{
        ar.sort(by: {$0.date! > $1.date!})
        
        var tempPeriod = [Shift]()
        var organizedPeriods = [[Shift]]()
        
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            for i in 0..<ar.count {
                
                if i == (ar.count-1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    
                } else if ar[i].newMonth == Int16(1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    tempPeriod.removeAll()
                    
                } else {
                    tempPeriod.append(ar[i])
                }
            }
            
        } else {
            if ar.count > 0 {
                var compare = [4000, 12, 12]
                let seperator = Int(UserDefaults().string(forKey: "newMonth")!)!
                
                for shift in ar {
                    let year = Int(String((Array(shift.date!.description))[0..<4]))!
                    let month = Int(String((Array(shift.date!.description))[5..<7]))!
                    let day = Int(String((Array(shift.date!.description))[8..<10]))!
                    
                    
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
        return organizedPeriods
    }
    
    static func organizeShiftsIntoPeriods(ar: inout [ShiftModel]) -> [[ShiftModel]]{
        ar.sort(by: {$0.date > $1.date})
        
        var tempPeriod = [ShiftModel]()
        var organizedPeriods = [[ShiftModel]]()
        
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            for i in 0..<ar.count {
                
                if i == (ar.count-1) {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    
                } else if ar[i].beginsNewPeriod {
                    tempPeriod.append(ar[i])
                    organizedPeriods.append(tempPeriod)
                    tempPeriod.removeAll()
                    
                } else {
                    tempPeriod.append(ar[i])
                }
            }
            
        } else {
            if ar.count > 0 {
                var compare = [4000, 12, 12]
                let seperator = Int(UserDefaults().string(forKey: "newMonth")!)!
                
                for shift in ar {
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
        return organizedPeriods
    }
}
