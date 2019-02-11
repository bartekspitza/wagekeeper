//
//  EditShift.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-11.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class EditVC: AddVC {
    
    let shift = shifts[shiftToEdit[0]][shiftToEdit[1]]
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Edit shift"
        configureTable()
        configureToolbar()
        configurePickers()
        createTitleField()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let newShift = ShiftModel(
            date: datePicker.date,
            endingTime: endingTimePicker.date,
            startingTime: startingTimePicker.date,
            lunchTime: breakField.text!,
            note: titleField.text!,
            newPeriod: periodSwitch.isOn ? Int16(1) : Int16(0)
        )
        newShift.ID = shift.ID
        shifts[shiftToEdit[0]][shiftToEdit[1]] = newShift
        
        CloudStorage.updateShift(from: shift, with: newShift, user: user.ID, completionHandler: {
            
            print("done with updating")
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            fillWithShiftInfo()
        }
    }
    
    func fillWithShiftInfo() {
        titleField.text = shift.note
        dateField.text = Time.dateToString(date: shift.date, withDayName: true)
        startingTimeField.text = Time.dateToTimeString(date: shift.startingTime)
        endingTimeField.text = Time.dateToTimeString(date: shift.endingTime)
        breakField.text = shift.lunchTime
        noteField.text = shift.note
        
        datePicker.date = shift.date
        startingTimePicker.date = shift.startingTime
        endingTimePicker.date = shift.endingTime
        periodSwitch.isOn = shift.beginsNewPeriod == Int16(1)
        
    }
}
