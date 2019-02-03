//
//  EditingTable.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-10-31.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class EditingTable: UITableViewController, UITextFieldDelegate {
    
    // Textfields
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var STField: UITextField!
    @IBOutlet weak var ETField: UITextField!
    @IBOutlet weak var lunchField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    
    // DatePickers
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let formatter = DateFormatter()
    let calendar = Calendar.current

    @IBOutlet weak var newMonthCell: UITableViewCell!
    @IBOutlet weak var mySwitch: UISwitch!
    var startFieldIsFocused = Bool()
    var STDate = Date()
    var ETDate = Date()
    let shift = shifts[indexx[0]][indexx[1]]
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var currentField = 0
    
    // Toolbar
    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noteField.delegate = self
        self.lunchField.delegate = self
        
        createDatePicker()
        createTimePicker()
        initiateFieldsAndPickers() //Initiates all fields and date from the chosen shift, and sets the currentTempShift accordingly
        createLunchAndNoteField()
        switchState() // Changes the switch to on or off depending if that shift starts a new month
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 5 {
            let textFields = [dateField, STField, ETField, lunchField, noteField]
            textFields[indexPath.row]?.becomeFirstResponder()
        }
    }
    
    // Textfield functions triggered when change in that textfield occurs
    @objc func datePickerChanged(sender: UIDatePicker) {
        dateField.text = createDateString(Date: sender.date)
        currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
    }
    @objc func timePickerChanged(sender: UIDatePicker) {
        if startFieldIsFocused {
            STDate = timePicker.date
            STField.text = createTimeString(Date: STDate)
            currentTempShift.startingTime = STDate
            currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
        } else {
            ETDate = timePicker.date
            ETField.text = createTimeString(Date: ETDate)
            currentTempShift.endingTime = ETDate
        }
    }
    @objc func lunchFieldChanged(sender: UITextField) {
        currentTempShift.lunchTime = lunchField.text!
    }
    @objc func noteFieldChanged(sender: UITextField) {
        currentTempShift.note = noteField.text!
    }
    
    
    @IBAction func lunchSet(_ sender: UITextField) {
        if lunchField.text == "" {
            lunchField.text = "0"
            currentTempShift.lunchTime = lunchField.text!
        }
    }
    
    // Tells timePicker which field is currently focused
    @IBAction func datePressed(_ sender: UITextField) {
        currentField = 0
    }
    
    @IBAction func STPressed(_ sender: UITextField) {
        currentField = 1
        startFieldIsFocused = true
        timePicker.date = STDate
    }
    @IBAction func ETPressed(_ sender: UITextField) {
        currentField = 2
        startFieldIsFocused = false
        timePicker.date = ETDate
    }
    @IBAction func notePressed(_ sender: UITextField) {
        currentField = 4
    }
    @IBAction func switchPressed(_ sender: UISwitch) {
        if mySwitch.isOn {
            currentTempShift.newPeriod = Int16(1)
        } else {
            currentTempShift.newPeriod = Int16(0)
        }
        self.view.endEditing(true)
    }
    

    @IBAction func lunchPressed(_ sender: UITextField) {
        currentField = 3
        currentTempShift.lunchTime = ""
    }
    
    // Date functions
    func createDateString(Date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: Date)
        let dayName = days[calendar.component(.weekday, from: Date)-1]
        
        return dayName + ", " + dateString.replacingOccurrences(of: ",", with: "")
    }
    func createTimeString(Date: Date) -> String {
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let timeString = formatter.string(from: Date)
        return timeString
    }
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        
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
    
    @objc func prevField(sender: UIBarButtonItem) {
        if currentField == 1 {
            dateField.becomeFirstResponder()
        } else if currentField == 2 {
            STField.becomeFirstResponder()
        } else if currentField == 3 {
            ETField.becomeFirstResponder()
        } else if currentField == 4 {
            lunchField.becomeFirstResponder()
        }
    }
    @objc func nextField(sender: UIBarButtonItem) {
        if currentField == 0 {
            STField.becomeFirstResponder()
        } else if currentField == 1 {
            ETField.becomeFirstResponder()
        } else if currentField == 2 {
            lunchField.becomeFirstResponder()
        } else if currentField == 3 {
            noteField.becomeFirstResponder()
        }
    }
    
    // Create textfield pickers (Called in viewDidLoad)
    func createDatePicker() {
        dateField.inputAccessoryView = toolbar
        dateField.inputView = datePicker
        datePicker.datePickerMode = .date
        dateField.tintColor = UIColor.clear
        datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
    }
    func createTimePicker() {
        timePicker.addTarget(self, action: #selector(timePickerChanged), for: UIControlEvents.valueChanged)
        timePicker.datePickerMode = .time
        
        ETField.inputAccessoryView = toolbar
        STField.inputAccessoryView = toolbar
        ETField.tintColor = UIColor.clear
        STField.tintColor = UIColor.clear
        ETField.inputView = timePicker
        STField.inputView = timePicker
        ETField.addTarget(self, action: #selector(ETPressed(_:)), for: UIControlEvents.editingDidBegin)
        STField.addTarget(self, action: #selector(STPressed(_:)), for: UIControlEvents.editingDidBegin)
    }
    func createLunchAndNoteField() {
        let imageDown = UIImage(named: "downBtn")
        let imageUp = UIImage(named: "upBtn")
        let size = 45
        
        let downBtn = UIBarButtonItem(image: imageDown?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItemStyle.done, target: self, action: #selector(nextField(sender:)))
        let upBtn = UIBarButtonItem(image: imageUp?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItemStyle.done, target: self, action: #selector(prevField(sender:)))
        
        upBtn.tintColor = navColor
        downBtn.tintColor = navColor
        doneButton.tintColor = navColor
        
        toolbar.setItems([upBtn, downBtn, flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        lunchField.inputAccessoryView = toolbar
        noteField.inputAccessoryView = toolbar
        noteField.autocapitalizationType = .sentences
        lunchField.keyboardType = .numberPad
        lunchField.clearsOnBeginEditing = true
        noteField.addTarget(self, action: #selector(noteFieldChanged(sender:)), for: .editingChanged)
        lunchField.addTarget(self, action: #selector(lunchFieldChanged(sender:)), for: .editingChanged)
        lunchField.tintColor = navColor
        noteField.tintColor = navColor
    }
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    
    // Tableview functions
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 15, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.systemFont(ofSize: 12)
        headerLabel.textColor = UIColor(red: 0.265, green: 0.294, blue: 0.367, alpha: 1.0)
        headerLabel.text = "SHIFT INFORMATION"
        headerLabel.sizeToFit()
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            return 6
        } else {
            return 5
        }
    }
    func initiateFieldsAndPickers() {
        dateField.text = createDateString(Date: shift.date!)
        STField.text = createTimeString(Date: shift.startingTime!)
        ETField.text = createTimeString(Date: shift.endingTime!)
        lunchField.text = shift.lunchTime
        noteField.text = shift.note
        datePicker.date = shift.date!
        STDate = shift.startingTime!
        ETDate = shift.endingTime!
        
        currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
        currentTempShift.startingTime = STDate
        currentTempShift.endingTime = ETDate
        currentTempShift.note = noteField.text!
        currentTempShift.lunchTime = lunchField.text!
    }
    
    func switchState() {
        if shift.newMonth == Int16(1) {
            mySwitch.isOn = true
            currentTempShift.newPeriod = Int16(1)
        } else {
            mySwitch.isOn = false
            currentTempShift.newPeriod = Int16(0)
        }
        mySwitch.onTintColor = navColor
    }
}
