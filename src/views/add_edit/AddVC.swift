//
//  AddShiftVC.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-08.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class AddVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    let TITLES = ["Date", "Duration", "Break (minutes)", "Note"]
    
    var table: UITableView!
    
    var titleField = UITextField()
    var dateField = UITextField()
    var startingTimeField = UITextField()
    var endingTimeField = UITextField()
    var breakField = UITextField()
    var noteField = UITextView()
    var periodSwitch = UISwitch()
    
    let datePicker = UIDatePicker()
    let startingTimePicker = UIDatePicker()
    let endingTimePicker = UIDatePicker()
    
    var btn: UIButton!
    var toolbar: UIToolbar!
   
    var currentField: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add shift"
        self.hideKeyboardWhenTappedAround()

        
        configureFields()
        configureToolbar()
        createTitleField()
        configureTable()
        configurePickers()
        createAddShiftButton()
    }
    
    func configureFields() {
        dateField.text = Time.dateToString(date: Date(), withDayName: true)
        startingTimeField.text = Time.dateToTimeString(date: user.settings.startingTime) + "  -  "
        endingTimeField.text = Time.dateToTimeString(date: user.settings.endingTime)
        breakField.text = user.settings.breakTime.description
        noteField.text = "Additional notes.."
        noteField.textColor = .lightGray
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func onButtonPress() {
       
        let shift = ShiftModel(
            title: (titleField.text! == "") ? "No title" : titleField.text!,
            date: datePicker.date,
            startingTime: startingTimePicker.date,
            endingTime: endingTimePicker.date,
            breakTime: (breakField.text! == "") ? 0 : Int(breakField.text!)!,
            note: (noteField.text! == "Additional notes..") ? "" : noteField.text!,
            newPeriod: periodSwitch.isOn,
            ID: ""
        )
        
        CloudStorage.addShift(toUser: user.ID, shift: shift, completionHandler: {
            CloudStorage.updateSetting(toUser: user.ID, obj: ["lastAddedShift": Date()])
        })
        
        Periods.insert(shift: shift)
        shiftsNeedsReOrganizing = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func createTitleField() {
        let height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        titleField = UITextField(frame: CGRect(x: 0, y: height, width: self.view.frame.width, height: self.view.frame.height*0.10))
        titleField.placeholder = "Shift title"
        titleField.delegate = self
        titleField.textAlignment = .center
        titleField.text = user.settings.title
        titleField.font = UIFont.systemFont(ofSize: 25, weight: .light)
        titleField.adjustsFontSizeToFitWidth = true
        titleField.inputAccessoryView = toolbar
        titleField.tag = 0
        titleField.addBottomBorder(color: UIColor.black.withAlphaComponent(0.1), width: 0.5)
        self.view.addSubview(titleField)
    }
    func createAddShiftButton() {
        btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.15)
        btn.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - btn.frame.height/2)
        btn.backgroundColor = Colors.theme
        btn.setTitle("Add shift", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(onButtonPress), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    func configurePickers() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        startingTimePicker.addTarget(self, action: #selector(startingTimePickerChanged), for: .valueChanged)
        startingTimePicker.datePickerMode = .time
        startingTimePicker.date = user.settings.startingTime
        
        endingTimePicker.addTarget(self, action: #selector(endingTimePickerChanged), for: .valueChanged)
        endingTimePicker.datePickerMode = .time
        endingTimePicker.date = user.settings.endingTime
    }
    
    func configureToolbar() {
        toolbar = UIToolbar()
        let buttons = addButtons(bar: toolbar, withUpAndDown: true, color: .black)
        buttons[0].action = #selector(donePressed)
        buttons[1].action = #selector(prevField)
        buttons[2].action = #selector(nextField)
    }
    func configureTable() {
        let height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.frame = CGRect(x: 0, y: height + titleField.frame.height + 20, width: self.view.frame.width, height: self.view.frame.height*0.85 - height - 20 - titleField.frame.height)
        table.tableFooterView = UIView()
        table.isScrollEnabled = true
        table.separatorColor = UIColor.black.withAlphaComponent(0.11)
        table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.register(InputCell.self, forCellReuseIdentifier: "MyCell")
        
        self.view.addSubview(table)
    }
    
    @objc func datePickerChanged() {
        dateField.text = Time.dateToString(date: datePicker.date, withDayName: true)
    }
    @objc func startingTimePickerChanged() {
        startingTimeField.text = Time.dateToTimeString(date: startingTimePicker.date) + "  -  "
        let size = startingTimeField.text!.sizeOfString(usingFont: startingTimeField.font!)
        endingTimeField.frame.origin.x = 10 + size.width
    }
    @objc func endingTimePickerChanged() {
        endingTimeField.text = Time.dateToTimeString(date: endingTimePicker.date)
    }
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    @objc func prevField() {
        let fields = [titleField, dateField, startingTimeField, endingTimeField, breakField]
        if currentField > 0 {
            fields[currentField-1].becomeFirstResponder()
        }
    }
    @objc func nextField() {
        let fields = [dateField, startingTimeField, endingTimeField, breakField, noteField]
        if currentField < 5 {
            fields[currentField].becomeFirstResponder()
        }
    }
    
    
    // Note field
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Additional notes.."
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentField = textView.tag
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "0"
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentField = textField.tag
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 4 {
            let headerView = UIView(frame: CGRect(x: 10, y: 0, width: 0, height: 0))
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 13))
            lbl.text = "   " + TITLES[section]
            lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            lbl.textColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
            
            headerView.addSubview(lbl)
            return headerView
        } else {
            return UIView()
        }
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        if section != 4 {
            view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "MyCell")! as! InputCell
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {

            let tmp = dateField.text
            dateField = cell.field1
            dateField.frame = CGRect(x: 10, y: 0, width: self.view.frame.width, height: 30)
            dateField.inputAccessoryView = toolbar
            dateField.inputView = datePicker
            dateField.tintColor = UIColor.clear
            dateField.text = tmp //Time.dateToString(date: Date(), withDayName: true)
            dateField.delegate = self
            dateField.tag = 1
            dateField.font = UIFont.systemFont(ofSize: 17, weight: .light)
            
        } else if indexPath.section == 1 {
            var tmp = startingTimeField.text
            startingTimeField = cell.field1
            startingTimeField.frame = CGRect(x: 10, y: 0, width: 100, height: 30)
            startingTimeField.inputView = startingTimePicker
            startingTimeField.tintColor = UIColor.clear
            startingTimeField.inputAccessoryView = toolbar
            startingTimeField.text = tmp //Time.dateToTimeString(date: user.settings.startingTime) + "  -  "
            startingTimeField.tag = 2
            startingTimeField.delegate = self
            startingTimeField.font = UIFont.systemFont(ofSize: 17, weight: .light)
            
            tmp = endingTimeField.text
            let textSize = startingTimeField.text!.sizeOfString(usingFont: startingTimeField.font!)
            endingTimeField = cell.field2
            endingTimeField.frame = CGRect(x: textSize.width + 10, y: 0, width: 100, height: 30)
            endingTimeField.inputView = endingTimePicker
            endingTimeField.tintColor = UIColor.clear
            endingTimeField.inputAccessoryView = toolbar
            endingTimeField.text = tmp //Time.dateToTimeString(date: user.settings.endingTime)
            endingTimeField.tag = 3
            endingTimeField.delegate = self
            endingTimeField.font = UIFont.systemFont(ofSize: 17, weight: .light)
            
        } else if indexPath.section == 2 {
            let tmp = breakField.text
            breakField = cell.field1
            breakField.frame = CGRect(x: 10, y: 0, width: self.view.frame.width, height: 30)
            breakField.text = tmp
            breakField.placeholder = "How much break did you take?"
            breakField.delegate = self
            breakField.keyboardType = .numberPad
            breakField.tag = 4
            breakField.inputAccessoryView = toolbar
            breakField.font = UIFont.systemFont(ofSize: 17, weight: .light)
            
            cell.contentView.addSubview(breakField)
        } else if indexPath.section == 3 {
            let tmp = noteField.text
            let tmp1 = noteField.textColor
            noteField = cell.textView
            noteField.frame = CGRect(x: 5, y: 0, width: self.view.frame.width, height: 70)
            noteField.textAlignment = .left
            noteField.autocapitalizationType = .sentences
            noteField.text = tmp //"Additional notes.."
            noteField.textColor = tmp1
            noteField.delegate = self
            noteField.inputAccessoryView = toolbar
            noteField.tag = 5
            noteField.font = UIFont.systemFont(ofSize: 15, weight: .light)
            
            cell.contentView.addSubview(noteField)
        } else if indexPath.section == 4 {

            cell.lbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
            cell.lbl.text = "This shift marks a new period"
            cell.lbl.font = UIFont.systemFont(ofSize: 17, weight: .light)
            cell.lbl.center.y = 20
            cell.lbl.sizeToFit()
            
            let tmp = periodSwitch.isOn
            periodSwitch = cell.cellSwitch
            cell.cellSwitch.isOn = tmp
            cell.cellSwitch.onTintColor = Colors.theme
            cell.cellSwitch.frame.origin.x = cell.lbl.frame.width + 20
            cell.cellSwitch.isHidden = false
            cell.view.frame = CGRect(x: 0, y: 0, width: cell.lbl.frame.width + 20 + periodSwitch.frame.width, height: 40)
            cell.view.center = CGPoint(x: self.view.center.x, y: 20)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            return 0
        }
        return 13
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 70
        } else if indexPath.section == 4 {
            return 40
        }
        return 30
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return (user.settings.newPeriod == 0) ? 5 : 4
    }
}
