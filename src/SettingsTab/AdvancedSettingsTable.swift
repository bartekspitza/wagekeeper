//
//  AdvancedSettingsTable.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-27.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class AdvancedSettingsTable: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {

    // IBOutlets
    @IBOutlet var daysCells: [UITableViewCell]!
    @IBOutlet weak var minHoursField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var lunchField: UITextField!
    @IBOutlet weak var STField: UITextField!
    @IBOutlet weak var ETField: UITextField!
    @IBOutlet weak var autoTextField: UITextField!
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var automaticallyLbl: UILabel!
    
    // Other
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let timePicker = UIDatePicker()
    var startFieldIsFocused = false
    var STDate = Date()
    var ETDate = Date()
    let picker = UIPickerView()
    let range = Array(1..<28)
    
    // Toolbar
    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tintColor = navColor
        tableView.tableFooterView = UIView()
        self.navigationItem.title = "Advanced tools"
        

        configureToolbar()
        configurePicker()
        createTimePicker()
        configureMinHoursField()
        configureNoteLunchField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserDefaults()
        configureDaysCells()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            if autoTextField.text == "" && mySwitch.isOn == false || mySwitch.isOn {
                UserDefaults().set(true, forKey: "manuallyNewMonth")
                UserDefaults().set("1", forKey: "newMonth")
            } else {
                UserDefaults().set(false, forKey: "manuallyNewMonth")
            }
        }
    }
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["bartekspitza@hotmail.com"])
        composeVC.setSubject(appName)
        composeVC.setMessageBody("\(appName) \(appBuild) Please write under this line", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    internal func mailComposeController(_ controller: MFMailComposeViewController,
                                       didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "https://itunes.apple.com/app/\(appId)?action=write-review") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func configureToolbar() {
        toolbar.sizeToFit()
        toolbar.setItems([flexSpace, doneButton], animated: false)
        doneButton.tintColor = navColor
    }
    
    func configurePicker() {
        self.picker.delegate = self
        self.picker.dataSource = self
        autoTextField.inputAccessoryView = toolbar
        autoTextField.tintColor = UIColor.clear
        autoTextField.inputView = picker
    }
    
    func configureNoteLunchField() {
        noteField.inputAccessoryView = toolbar
        lunchField.inputAccessoryView = toolbar
        noteField.autocapitalizationType = .sentences
        lunchField.keyboardType = .numberPad
        lunchField.clearsOnBeginEditing = true
    }
    
    
    @objc func timePickerChanged(sender: UIDatePicker) {
        if startFieldIsFocused {
            STDate = timePicker.date
            STField.text = createTime(Date: STDate)
            UserDefaults().set(STDate, forKey: "defaultST")
        } else {
            ETDate = timePicker.date
            ETField.text = createTime(Date: ETDate)
            UserDefaults().set(ETDate, forKey: "defaultET")
        }
    }
    
    @IBAction func noteSet(_ sender: UITextField) {
        UserDefaults().setValue(noteField.text!, forKey: "defaultNote")
    }
    
    @IBAction func lunchSet(_ sender: UITextField) {
        if lunchField.text == "" {
            lunchField.text = "0"
            UserDefaults().setValue(lunchField.text, forKey: "defaultLunch")
        } else {
            UserDefaults().setValue(lunchField.text, forKey: "defaultLunch")
        }
    }
    
    @IBAction func STPressed(_ sender: UITextField) {
        startFieldIsFocused = true
        STField.text = createTime(Date: STDate)
        timePicker.date = STDate
        
        if UserDefaults().value(forKey: "defaultET") == nil {
            ETDate = STDate
        }
        UserDefaults().set(STDate, forKey: "defaultST")
    }
    
    @IBAction func ETPressed(_ sender: Any) {
        startFieldIsFocused = false
        ETField.text = createTime(Date: ETDate)
        timePicker.date = ETDate
        
        UserDefaults().set(ETDate, forKey: "defaultET")
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        let duration = 0.25
        if mySwitch.isOn {
            autoTextField.isEnabled = false

            
            UIView.transition(with: automaticallyLbl, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.automaticallyLbl.textColor = UIColor.lightGray
            }), completion: nil)
            UIView.transition(with: autoTextField, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.autoTextField.textColor = UIColor.lightGray
                self.autoTextField.attributedPlaceholder = NSAttributedString(string:"Tap to enter..", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
            }), completion: nil)
            
        } else {
            autoTextField.isEnabled = true
            
            UIView.transition(with: automaticallyLbl, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.automaticallyLbl.textColor = UIColor.black
            }), completion: nil)
            
            UIView.transition(with: autoTextField, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.autoTextField.textColor = UIColor.black
                self.autoTextField.attributedPlaceholder = NSAttributedString(string:"Tap to enter..", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
            }), completion: nil)
            
        }
    }
    
    func configureDaysCells() {
        for i in 0..<daysCells.count {
            daysCells[i].selectionStyle = .default
            daysCells[i].tintColor = navColor
            
            if UserDefaults().value(forKey: days[i]) != nil {
                daysCells[i].accessoryType = .checkmark
            } else {
                daysCells[i].accessoryType = .disclosureIndicator
            }
        }
    }
    
    func loadUserDefaults() {
        // Mininum hours
        minHoursField.text = UserDefaults().string(forKey: "minHours")
        // Starting time
        STDate = UserDefaults().value(forKey: "defaultST") as! Date
        STField.text = createTime(Date: STDate)
        // Ending time
        ETDate = UserDefaults().value(forKey: "defaultET") as! Date
        ETField.text = createTime(Date: ETDate)
        // Note
        noteField.text = UserDefaults().string(forKey: "defaultNote")
        // Lunch
        lunchField.text = UserDefaults().string(forKey: "defaultLunch")
        // Closing date
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            autoTextField.text = "1st"
            autoTextField.textColor = .lightGray
            automaticallyLbl.textColor = .lightGray
            mySwitch.isOn = true
        } else {
            automaticallyLbl.textColor = .black
            mySwitch.isOn = false
            if [1, 21].contains(Int(UserDefaults().string(forKey: "newMonth")!)!) {
                autoTextField.text = UserDefaults().string(forKey: "newMonth")! + "st"
            } else if [2, 22].contains(Int(UserDefaults().string(forKey: "newMonth")!)!) {
                autoTextField.text = UserDefaults().string(forKey: "newMonth")! + "nd"
            } else if [3, 23].contains(Int(UserDefaults().string(forKey: "newMonth")!)!) {
                autoTextField.text = UserDefaults().string(forKey: "newMonth")! + "rd"
            } else {
                autoTextField.text = UserDefaults().string(forKey: "newMonth")! + "th"
            }
            picker.selectRow(Int(UserDefaults().string(forKey: "newMonth")!)!-1, inComponent: 0, animated: true)
        }
    }
    
    
    
    func configureMinHoursField() {
        minHoursField.keyboardType = .decimalPad
        minHoursField.clearsOnBeginEditing = true
        minHoursField.inputAccessoryView = toolbar
        mySwitch.onTintColor = navColor
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 {
            return 30
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 4 {
            let versionText = UILabel()
            versionText.text = appName + " " + appBuild
            versionText.textAlignment = .center
            versionText.center = CGPoint(x: self.view.frame.width/2, y: 0)
            versionText.textColor = .darkGray
            versionText.font = UIFont.systemFont(ofSize: 12)

            return versionText 
        } else {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 3 {
            let message = "Only change this setting if you sometimes work less hours than you actually get paid for. For example, changing this to 4 will cause any shifts shorter than 4 hours to be considered as 4 hours in length in calculations."
            let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        // Closing date detailbutton
        } else if indexPath.section == 2 {
            let message = "Turning this on enables you to manually choose which shift should be the beginning of a new period, regardless of the shifts date."
            let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            day = days[indexPath.row]
            performSegue(withIdentifier: "OTRuleSegue", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                noteField.becomeFirstResponder()
            } else if indexPath.row == 1 {
                lunchField.becomeFirstResponder()
            } else if indexPath.row == 2 {
                STField.becomeFirstResponder()
            } else {
                ETField.becomeFirstResponder()
            }
            
        } else if indexPath.section == 2 && indexPath.row == 0 && !mySwitch.isOn{
            autoTextField.becomeFirstResponder()
        } else if indexPath.section == 3 {
            minHoursField.becomeFirstResponder()
        } else if indexPath.section == 4 {
            if indexPath.row == 0 {
                sendEmail()
            } else {
                rateApp(appId: "id1312943979", completion: { success in
                    print("RateApp \(success)")
                })
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return range.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(range[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults().set(String(row + 1), forKey: "newMonth")

        if [1, 21].contains((row + 1)) {
            autoTextField.text = String(row + 1) + "st"
        } else if [2, 22].contains((row + 1)) {
            autoTextField.text = String(row + 1) + "nd"
        } else if [3, 23].contains((row + 1)) {
            autoTextField.text = String(row + 1) + "rd"
        } else {
            autoTextField.text = String(row + 1) + "th"
        }
    }
    
    @IBAction func minHoursSet(_ sender: UITextField) {
        if minHoursField.text == "" {
            minHoursField.text = "0"
            UserDefaults().set(minHoursField.text!.floatValue, forKey: "minHours")
        } else {
            UserDefaults().set(minHoursField.text!.floatValue, forKey: "minHours")
        }
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
    
    func createTime(Date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date)
        
        return dateString
    }
    
    // Enables deletion of all rules in given OT Day
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let deleteAction = UITableViewRowAction(style: .normal, title: "Delete rules")   { (_ rowAction: UITableViewRowAction, _ indexPath: IndexPath) in

                // Removing defaults for day
                UserDefaults().set(nil, forKey: self.days[indexPath.row])
                tableView.cellForRow(at: indexPath)?.accessoryType = .disclosureIndicator
               
            }
            deleteAction.backgroundColor = .gray
            return [deleteAction]
        } else {
            return [UITableViewRowAction()]
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && (UserDefaults().value(forKey: days[indexPath.row]) != nil)
    }
}
