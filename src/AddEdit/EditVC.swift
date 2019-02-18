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
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.title = "Edit shift"
        createTitleField()
        configureTable()
        configureToolbar()
        configurePickers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let newShift = ShiftModel(
            title: titleField.text!,
            date: datePicker.date,
            startingTime: startingTimePicker.date,
            endingTime: endingTimePicker.date,
            breakTime: (breakField.text! == "") ? 0 : Int(breakField.text!)!,
            note: (noteField.text! == "Additional notes..") ? "" : noteField.text!,
            newPeriod: periodSwitch.isOn,
            ID: shift.ID
        )
        
        if shift.isEqual(to: newShift) {
            // do nothing
        } else {
            shifts[shiftToEdit[0]][shiftToEdit[1]] = newShift
            CloudStorage.updateShift(from: shift, with: newShift, user: user.ID, completionHandler: {})
            shiftsNeedsReOrganizing = true
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            fillWithShiftInfo()
            configureNoteField()
        }
    }
    
    func configureNoteField() {
        if noteField.text == "" {
            noteField.text = "Additional notes.."
        } else if noteField.text != "Additional notes.." {
            noteField.textColor = .black
        }
    }
    
    func fillWithShiftInfo() {
        // Fills all fields, pickers and the switch according to the information from the chosen shift
        titleField.text = shift.title
        dateField.text = Time.dateToString(date: shift.date, withDayName: true)
        startingTimeField.text = Time.dateToTimeString(date: shift.startingTime)
        endingTimeField.text = Time.dateToTimeString(date: shift.endingTime)
        breakField.text = shift.breakTime.description
        noteField.text = shift.note
        
        datePicker.date = shift.date
        startingTimePicker.date = shift.startingTime
        endingTimePicker.date = shift.endingTime
        periodSwitch.isOn = shift.beginsNewPeriod
    }
}
