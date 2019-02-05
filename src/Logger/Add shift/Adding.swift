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
            
            let shift = ShiftModel(
                date: currentTempShift.date,
                endingTime: currentTempShift.endingTime,
                startingTime: currentTempShift.startingTime,
                lunchTime: currentTempShift.lunchTime,
                note: currentTempShift.note,
                newPeriod: currentTempShift.newPeriod
            )
            LocalStorage.insertShift(shift: shift)
            
            performSegue(withIdentifier: "gotoadd", sender: self)
            shouldFetchAllData = true
        }
    }
}
