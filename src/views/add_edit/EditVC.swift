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
        makeTableTaller()
        fillWithShiftInfo()
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
            CloudStorage.updateShift(from: shift, with: newShift, user: user.ID, completionHandler: {
                CloudStorage.updateSetting(toUser: user.ID, obj: [
                    "lastAddedShift": Date(),
                    "iosVersion": appBuild,
                    "locale": Calendar.current.locale?.identifier ?? "missing",
                    "timeZone": TimeZone.current.identifier
                    ])
            })
            shiftsNeedsReOrganizing = true
        }
    }
    
    func fillWithShiftInfo() {
        titleField.text = shift.title
        dateField.text = Time.dateToString(date: shift.date, withDayName: true)
        startingTimeField.text = Time.dateToTimeString(date: shift.startingTime) + "  -  "
        endingTimeField.text = Time.dateToTimeString(date: shift.endingTime)
        breakField.text = shift.breakTime.description
        noteField.text = shift.note == "" ? "Additional notes.." : shift.note
        noteField.textColor = shift.note == "" ? UIColor.lightGray : UIColor.black
        
        datePicker.date = shift.date
        startingTimePicker.date = shift.startingTime
        endingTimePicker.date = shift.endingTime
        periodSwitch.isOn = shift.beginsNewPeriod
    }
    
    func makeTableTaller() {
        let height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        
        table.frame = CGRect(x: 0, y: height + titleField.frame.height + 20, width: self.view.frame.width, height: self.view.frame.height - height - 20 - titleField.frame.height)
    }
}
