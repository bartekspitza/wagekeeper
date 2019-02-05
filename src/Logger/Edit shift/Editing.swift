//
//  Editing.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-10-31.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import CoreData

class Editing: UIViewController {

    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        saveBtn.backgroundColor = navColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    @IBAction func save(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shiftToUpdate = LocalStorage.organizedValues[shiftToEdit[0]][shiftToEdit[1]]
        context.delete(shiftToUpdate)
        
        let newShift = ShiftModel(
            date: currentTempShift.date,
            endingTime: currentTempShift.endingTime,
            startingTime: currentTempShift.startingTime,
            lunchTime: currentTempShift.lunchTime,
            note: currentTempShift.note,
            newPeriod: currentTempShift.newPeriod
        )
        
        context.insert(newShift.toCoreData())
        
        do {
            try context.save()
            
        } catch {
            print(error)
        }
        
        performSegue(withIdentifier: "goback", sender: self)
    }
}
