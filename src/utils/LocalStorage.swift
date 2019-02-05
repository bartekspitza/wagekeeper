//
//  LocalStorage.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-04.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class LocalStorage {
    static func getAllShifts() -> [Shift] {
        var shiftsFromLocalStorage = [Shift]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            shiftsFromLocalStorage = try context.fetch(Shift.fetchRequest())
        } catch {
            print("could not get the shift object")
        }
        return shiftsFromLocalStorage
    }
    
    static func insertExampleShift() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shift = Shift(context: context)
        shift.date = Date()
        shift.endingTime = Time.createDefaultET()
        shift.startingTime = Time.createDefaultST()
        shift.lunchTime = "60"
        shift.note = "Example (Delete this)"
        shift.newMonth = Int16(0)
        
        shifts.append([ShiftModel.createFromCoreData(s: shift)])
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
