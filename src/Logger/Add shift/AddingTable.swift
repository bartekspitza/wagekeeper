//
//  AddingTable.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-10-29.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

struct tempShift {
    var date: Date
    var endingTime: Date
    var startingTime: Date
    var lunchTime: String
    var note: String
    var newPeriod: Int16
    var shiftComplete: [Bool]
}

class AddingTable: UITableViewController, UITextFieldDelegate {
    
    //Cell labels
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var STLbl: UILabel!
    @IBOutlet weak var ETLbl: UILabel!
    
    // TextFields
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
    @IBOutlet var myTableView: UITableView!
    var startFieldIsFocused = Bool()
    var STDate = Date()
    var ETDate = Date()
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var currentField = 0
    
    
    // Toolbar
    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.noteField.delegate = self
        self.lunchField.delegate = self
        
        markRequiredFields()
        createDatePicker()
        createTimePicker()
        createLunchNoteField()
        loadUserDefaults()
        initiateSwitch()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1)) // Gets rid of the last cell-seperator line
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 5 {
            let textFields = [dateField, STField, ETField, lunchField, noteField]
            textFields[indexPath.row]?.becomeFirstResponder()
        }
    }

        
    // Textfield functions triggered when change in that textfield occurs
    @objc func timePickerChanged(sender: UIDatePicker) {
        if startFieldIsFocused {
            STDate = timePicker.date
            STField.text = createTimeString(Date: STDate)
            currentTempShift.startingTime = STDate
            if currentTempShift.shiftComplete[0] {
                currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
            }
        } else {
            ETDate = timePicker.date
            ETField.text = createTimeString(Date: ETDate)
            currentTempShift.endingTime = ETDate
        }
    }
    @objc func datePickerChanged(sender: UIDatePicker) {
        dateField.text = createDateString(Date: sender.date)
        if currentTempShift.shiftComplete[1]{
            currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
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
    
    
    // Initiates textfields when pressed
    @IBAction func datePressed(_ sender: UITextField) {
        currentField = 0
        dateField.text = createDateString(Date: datePicker.date)
        datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        currentTempShift.shiftComplete[0] = true
        currentTempShift.date = datePicker.date
        if currentTempShift.shiftComplete[1]{
            currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
        } else if UserDefaults().value(forKey: "defaultST") != nil {
            currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
        }
        animateToBlack()
    }
    @IBAction func STPressed(_ sender: UITextField) {
        currentField = 1
        startFieldIsFocused = true
        STField.text = createTimeString(Date: STDate)
        timePicker.date = STDate
        
        currentTempShift.startingTime = STDate
        currentTempShift.shiftComplete[1] = true
        animateToBlack()
        if currentTempShift.shiftComplete[0]{
            currentTempShift.date = combineDateWithTime(date: datePicker.date, time: STDate)!
        }
    }
    @IBAction func ETPressed(_ sender: UITextField) {
        currentField = 2
        startFieldIsFocused = false
        ETField.text = createTimeString(Date: ETDate)
        timePicker.date = ETDate
        
        currentTempShift.endingTime = ETDate
        currentTempShift.shiftComplete[2] = true
        animateToBlack()
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
    
    // Initializing functions
    func createDatePicker() {
        dateField.inputAccessoryView = toolbar
        dateField.inputView = datePicker
        datePicker.datePickerMode = .date
        dateField.tintColor = UIColor.clear
    }
    func createTimePicker() {
        timePicker.addTarget(self, action: #selector(timePickerChanged), for: UIControl.Event.valueChanged)
        timePicker.datePickerMode = .time
        
        ETField.inputAccessoryView = toolbar
        STField.inputAccessoryView = toolbar
        ETField.tintColor = UIColor.clear
        STField.tintColor = UIColor.clear
        ETField.inputView = timePicker
        STField.inputView = timePicker
        ETField.addTarget(self, action: #selector(ETPressed(_:)), for: UIControl.Event.editingDidBegin)
        STField.addTarget(self, action: #selector(STPressed(_:)), for: UIControl.Event.editingDidBegin)
    }
    func createLunchNoteField() {
        let imageDown = UIImage(named: "downBtn")
        let imageUp = UIImage(named: "upBtn")
        let size = 45
        
        let downBtn = UIBarButtonItem(image: imageDown?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: self, action: #selector(nextField(sender:)))
        let upBtn = UIBarButtonItem(image: imageUp?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: self, action: #selector(prevField(sender:)))

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
    func markRequiredFields() {
        dateLbl.textColor = .red
        STLbl.textColor = .red
        ETLbl.textColor = .red
    }
    func initiateSwitch() {
        mySwitch.onTintColor = navColor
        mySwitch.isOn = false
        
    }
    func loadUserDefaults() {
        // Starting Time
        if UserDefaults().value(forKey: "defaultST") != nil {
            STDate = UserDefaults().value(forKey: "defaultST") as! Date
            currentTempShift.startingTime = STDate
            STField.text = createTimeString(Date: STDate)
            STLbl.textColor = UIColor.black
        }
        // Ending Time
        if UserDefaults().value(forKey: "defaultET") != nil {
            ETDate = UserDefaults().value(forKey: "defaultET") as! Date
            currentTempShift.endingTime = ETDate
            ETField.text = createTimeString(Date: ETDate)
            ETLbl.textColor = UIColor.black
        }
        // Note
        if UserDefaults().string(forKey: "defaultNote") != nil && UserDefaults().string(forKey: "defaultNote") != "" {
            noteField.text = UserDefaults().string(forKey: "defaultNote")
        }
        // Lunch
        if UserDefaults().value(forKey: "defaultLunch") != nil && UserDefaults().string(forKey: "defaultLunch") != "" {
            lunchField.text = UserDefaults().string(forKey: "defaultLunch")
        }
    }
    
    
    // Tableview functions
    func animateToBlack() {
        if currentTempShift.shiftComplete[0] {
            UIView.transition(with: dateLbl, duration: 0.5, options: .transitionCrossDissolve, animations: ({
                self.dateLbl.textColor = UIColor.black
            }), completion: nil)
        }
        if currentTempShift.shiftComplete[1] {
            UIView.transition(with: STLbl, duration: 0.5, options: .transitionCrossDissolve, animations: ({
                self.STLbl.textColor = UIColor.black
            }), completion: nil)
        }
        if currentTempShift.shiftComplete[2] {
            UIView.transition(with: ETLbl, duration: 0.5, options: .transitionCrossDissolve, animations: ({
                self.ETLbl.textColor = UIColor.black
            }), completion: nil)
        }
    }
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
}
