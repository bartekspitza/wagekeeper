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
    
    
    @IBOutlet weak var table: UITableView!
    
    var titleField: UITextField!
    var dateField: UITextField!
    var startingTimeField: UITextField!
    var endingTimeField: UITextField!
    var breakField: UITextField!
    var noteField: UITextView!
    var periodSwitch: UISwitch!
    
    let datePicker = UIDatePicker()
    let startingTimePicker = UIDatePicker()
    let endingTimePicker = UIDatePicker()
    
    var btn: UIButton!
    
    // Toolbar
    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
   
    var currentField: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.title = "Add shift"
        configureToolbar()
        createTitleField()
        configureTable()
        configurePickers()
        createAddShiftButton()
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
        
        CloudStorage.addShift(toUser: user.ID, shift: shift, completionHandler: {})
        
        Periods.insert(shift: shift)
        shiftsNeedsReOrganizing = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func createTitleField() {
        let height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        titleField = UITextField(frame: CGRect(x: 0, y: height, width: self.view.frame.width, height: 75))
        titleField.placeholder = "Shift title"
        titleField.delegate = self
        titleField.textAlignment = .center
        titleField.text = UserSettings.getDefaultShiftName()
        titleField.font = UIFont.systemFont(ofSize: 25, weight: .light)
        titleField.inputAccessoryView = toolbar
        titleField.tag = 0
        self.view.addSubview(titleField)
    }
    func createAddShiftButton() {
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.1))
        btn.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - btn.frame.height/2)
        
        btn.backgroundColor = navColor
        btn.setTitle("Add shift", for: .normal)
        btn.addTarget(self, action: #selector(onButtonPress), for: .touchUpInside)
        
        self.view.addSubview(btn)
    }
    func configurePickers() {
        datePicker.datePickerMode = .date
        
        startingTimePicker.addTarget(self, action: #selector(startingTimePickerChanged), for: UIControl.Event.valueChanged)
        startingTimePicker.datePickerMode = .time
        startingTimePicker.date = UserSettings.getDefaultStartingTime()
        
        endingTimePicker.addTarget(self, action: #selector(endingTimePickerChanged), for: UIControl.Event.valueChanged)
        endingTimePicker.datePickerMode = .time
        endingTimePicker.date = UserSettings.getDefaultEndingTime()
    }
    func configureToolbar() {
        let imageDown = UIImage(named: "downBtn")
        let imageUp = UIImage(named: "upBtn")
        let size = 45
        
        let downBtn = UIBarButtonItem(image: imageDown?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: self, action: #selector(nextField(sender:)))
        let upBtn = UIBarButtonItem(image: imageUp?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: self, action: #selector(prevField(sender:)))
        
        upBtn.tintColor = .black
        downBtn.tintColor = .black
        doneButton.tintColor = .black
        toolbar.setItems([upBtn, downBtn, flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
    }
    func configureTable() {
        let height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        table.delegate = self
        table.dataSource = self
        table.frame = CGRect(x: 0, y: height + titleField.frame.height, width: self.view.frame.width, height: 595)
        table.tableFooterView = UIView()
        table.isScrollEnabled = false
    }
    
    @objc func startingTimePickerChanged() {
        startingTimeField.text = Time.dateToTimeString(date: startingTimePicker.date)
    }
    @objc func endingTimePickerChanged() {
        endingTimeField.text = Time.dateToTimeString(date: endingTimePicker.date)
    }
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    @objc func prevField(sender: UIBarButtonItem) {
        let fields = [titleField, dateField, startingTimeField, endingTimeField, breakField]
        if currentField > 0 {
            fields[currentField-1]?.becomeFirstResponder()
        }
    }
    @objc func nextField(sender: UIBarButtonItem) {
        let fields = [dateField, startingTimeField, endingTimeField, breakField, noteField]
        if currentField < 5 {
            fields[currentField]?.becomeFirstResponder()
        }
    }
    
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "FullTextFieldCell") as! FullTextFieldCell
        
        if indexPath.section == 0 {
            
            dateField = cell.field
            dateField.inputAccessoryView = toolbar
            dateField.inputView = datePicker
            dateField.tintColor = UIColor.clear
            dateField.text = Time.dateToString(date: Date(), withDayName: true)
            dateField.delegate = self
            dateField.tag = 1
            
        } else if indexPath.section == 1 {
            let cell = table.dequeueReusableCell(withIdentifier: "DurationCell") as! DurationCell
            startingTimeField = cell.startingField
            startingTimeField.inputView = startingTimePicker
            startingTimeField.tintColor = UIColor.clear
            startingTimeField.inputAccessoryView = toolbar
            startingTimeField.text = Time.dateToTimeString(date: UserSettings.getDefaultStartingTime())
            startingTimeField.tag = 2
            startingTimeField.delegate = self
            
            endingTimeField = cell.endingField
            endingTimeField.inputView = endingTimePicker
            endingTimeField.tintColor = UIColor.clear
            endingTimeField.inputAccessoryView = toolbar
            endingTimeField.text = Time.dateToTimeString(date: UserSettings.getDefaultEndingTime())
            endingTimeField.tag = 3
            endingTimeField.delegate = self
            
            cell.startingField.center = CGPoint(x: 10 + cell.startingField.frame.width/2, y: cell.startingField.center.y)
            cell.labelBetweenTimes.center = CGPoint(x: 10 + cell.startingField.frame.width + 3, y: cell.startingField.center.y)
            cell.endingField.center = CGPoint(x: 10 + cell.startingField.frame.width + 6 + cell.endingField.frame.width/2, y: cell.startingField.center.y)
            return cell
        } else if indexPath.section == 2 {
            breakField = cell.field
            breakField.text = UserSettings.getDefaultBreakTime()
            breakField.placeholder = "How much break did you take?"
            breakField.delegate = self
            breakField.keyboardType = .numberPad
            breakField.tag = 4
            breakField.inputAccessoryView = toolbar
            
        } else if indexPath.section == 3 {
            let cell = table.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
            noteField = cell.field
            noteField.textAlignment = .left
            noteField.autocapitalizationType = .sentences
            noteField.text = "Additional notes.."
            noteField.textColor = .lightGray
            noteField.delegate = self
            noteField.inputAccessoryView = toolbar
            noteField.tag = 5
            return cell
        } else if indexPath.section == 4 {
            let cell = table.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
            periodSwitch = cell.cellSwitch
            periodSwitch.isOn = false
            periodSwitch.tintColor = Colors.loggerSectionBG
            periodSwitch.onTintColor = Colors.loggerSectionBG
            if !UserSettings.newPeriodsManually() {
                cell.isHidden = true
            }
            return cell
        }

        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            return 0
        }
        return 13
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 70
        } else if indexPath.section == 4 {
            return 40
        }
        return 30
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
}
