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
    static var values = [Shift]()
    static var organizedValues = [[Shift]]()
    
    static func transferAllShiftsToCloud(loadingHandler: () -> ()) {
        if UserDefaults().bool(forKey: "hasLoggedInBefore") == false {
            
            let shifts = getAllShifts()
            
            if shifts.count > 0 {
                loadingHandler()
                print("going to try and batch write " + shifts.count.description + " items")
                CloudStorage.insertShifts(items: getAllShifts(), successHandler: {
                    UserDefaults().set(true, forKey: "hasLoggedInBefore")
                    print("in success handler of transfering all shifts")
                }, failureHandler: {
                    
                })
            }
        }
    }
    
    static func insertThousand() {
        print("going to insert thousand shifts to local storage")
        for _ in 0..<1000 {
            let shift = ShiftModel(title: "", date: Date(), startingTime: Date(), endingTime: Date(), breakTime: 0, note: "", newPeriod: false, ID: "")
            insertShift(shift: shift)
        }
    }
    
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
    
    static func insertShift(shift: ShiftModel) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.insert(shift.toCoreData())
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    static func insertExampleShift() {
        let shift = ShiftModel(
            title: "Example (Delete this)",
            date: Date(),
            startingTime: Time.createDefaultST(),
            endingTime: Time.createDefaultET(),
            breakTime: 60,
            note: "Any additional notes that you may have about a shift",
            newPeriod: false,
            ID: ""
        )
        LocalStorage.insertShift(shift: shift)
    }
}
