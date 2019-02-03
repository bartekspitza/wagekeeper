//
//  Adding.swift
//  adding shifts
//
//  Created by Bartek  on 2017-10-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import CoreData

var currentTempShift = tempShift(date: Date(), endingTime: Date(), startingTime: Date(), lunchTime: "", note: "Note missing", newPeriod: Int16(0), shiftComplete: [false, false, false])

class Adding: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var doneBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTempShift.date = Date()
        currentTempShift.newPeriod = Int16(0)
        if UserDefaults().value(forKey: "defaultST") != nil {
            currentTempShift.startingTime = UserDefaults().value(forKey: "defaultST") as! Date
        } else {
            currentTempShift.startingTime = Date()
        }
        if UserDefaults().value(forKey: "defaultET") != nil {
            currentTempShift.endingTime = UserDefaults().value(forKey: "defaultET") as! Date
        } else {
            currentTempShift.endingTime = Date()
        }
        currentTempShift.shiftComplete = [false, !(UserDefaults().value(forKey: "defaultST") == nil), !(UserDefaults().value(forKey: "defaultET") == nil)]
        
        if UserDefaults().string(forKey: "defaultNote") != nil && UserDefaults().string(forKey: "defaultNote") != "" {
            currentTempShift.note = UserDefaults().string(forKey: "defaultNote")!
        } else {
            currentTempShift.note = "Note Missing"
        }
        
        if UserDefaults().value(forKey: "defaultLunch") != nil && UserDefaults().string(forKey: "defaultLunch") != "" {
            currentTempShift.lunchTime = UserDefaults().string(forKey: "defaultLunch")!
        } else {
            currentTempShift.lunchTime = ""
        }
        
        doneBtn.backgroundColor = navColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    @IBAction func addShift(_ sender: UIButton) {
        if !(currentTempShift.shiftComplete.contains(false)) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let shift = Shift(context: context)
            shift.date = currentTempShift.date
            shift.endingTime = currentTempShift.endingTime
            shift.startingTime = currentTempShift.startingTime
            shift.lunchTime = currentTempShift.lunchTime
            shift.note = currentTempShift.note
            shift.newMonth = currentTempShift.newPeriod
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            performSegue(withIdentifier: "gotoadd", sender: self)
        }
    }
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = NSCalendar.current
        
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
