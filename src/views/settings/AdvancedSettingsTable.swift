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
    let sectionTitles = ["Overtime rules", "Default shift information", "When does a new period begin?"]
    let startingTimePicker = UIDatePicker()
    let endingTimePicker = UIDatePicker()
    let picker = UIPickerView()
    let range = Array(1..<28)
    
    // Toolbar
    var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Advanced tools"
        self.navigationController?.navigationBar.tintColor = .black
        
        configureTable()
        configureToolbar()
        configurePicker()
        createTimePicker()
        configureMinHoursField()
        configureNoteLunchField()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        populateWithSettings()
        configureDaysCells()
        mySwitch.onTintColor = Colors.theme
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let newPeriod = mySwitch.isOn ? 0 : picker.selectedRow(inComponent: 0) + 1
        
        if newPeriod != user.settings.newPeriod {
            user.settings.newPeriod = newPeriod
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["newPeriod": user.settings.newPeriod]])
        }
        
        if shiftsNeedsReOrganizing {
            Periods.reOrganize(successHandler: {
                Periods.organizePeriodsByYear(periods: shifts, successHandler: {
                    Periods.makePeriod(yearIndex: 0, monthIndex: 0, successHandler: {
                        shiftsNeedsReOrganizing = false
                    })
                })
            })
        }
    }
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["bartekspitza@hotmail.com"])
        composeVC.setSubject("\(appName) \(appBuild)")
        composeVC.setMessageBody("Account: " + user.email + "\n\nPlease don't remove above information. Write any suggestions, bugs etc, under this line.", isHTML: false)
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
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }

    @objc func datePickerDidChangeValue(sender: UIDatePicker) {
        if sender.tag == 1 {
            STField.text = Time.dateToTimeString(date: sender.date)
        } else {
            ETField.text = Time.dateToTimeString(date: sender.date)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 1 {
            user.settings.title = noteField.text!
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["title": user.settings.title]])
        } else if textField.tag == 2 {
            if lunchField.text == "" {
                lunchField.text = "0"
            }
            user.settings.breakTime = Int(lunchField.text!)!
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["break": user.settings.breakTime]])
        } else if textField.tag == 3 {
            user.settings.startingTime = startingTimePicker.date
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["starting": startingTimePicker.date]])
        } else if textField.tag == 4 {
            user.settings.endingTime = endingTimePicker.date
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["ending": endingTimePicker.date]])
        } else if textField.tag == 5 {
            if textField.text == "" {
                textField.text = "0"
            } else {
                if Int(textField.text!)! > 24 {
                    textField.text = String(24)
                }
            }
            user.settings.minimumHours = Int(textField.text!)!
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["minimumHours": Int(textField.text!)!]])
            shiftsNeedsReOrganizing = true
        }
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        shiftsNeedsReOrganizing = !shiftsNeedsReOrganizing
        let duration = 0.25
        if mySwitch.isOn {
            autoTextField.isEnabled = false

            UIView.transition(with: automaticallyLbl, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.automaticallyLbl.textColor = UIColor.lightGray
            }), completion: nil)
            UIView.transition(with: autoTextField, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.autoTextField.textColor = UIColor.lightGray
                self.autoTextField.attributedPlaceholder = NSAttributedString(string:"Tap to enter..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            }), completion: nil)
            
        } else {
            autoTextField.isEnabled = true
            
            UIView.transition(with: automaticallyLbl, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.automaticallyLbl.textColor = UIColor.black
            }), completion: nil)
            
            UIView.transition(with: autoTextField, duration: duration, options: .transitionCrossDissolve, animations: ({
                self.autoTextField.textColor = UIColor.black
                self.autoTextField.attributedPlaceholder = NSAttributedString(string:"Tap to enter..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            }), completion: nil)
        }
    }
    
    func configureToolbar() {
        toolbar = UIToolbar()
        let buttons = toolbar.addButtons(withUpAndDown: false, color: .black)
        buttons[0].action = #selector(donePressed)
    }
    
    func configurePicker() {
        self.picker.delegate = self
        self.picker.dataSource = self
        autoTextField.inputAccessoryView = toolbar
        autoTextField.tintColor = UIColor.clear
        autoTextField.inputView = picker
    }
    
    func configureNoteLunchField() {
        noteField.delegate = self
        noteField.inputAccessoryView = toolbar
        lunchField.inputAccessoryView = toolbar
        lunchField.delegate = self
        noteField.autocapitalizationType = .sentences
        lunchField.keyboardType = .numberPad
        lunchField.clearsOnBeginEditing = true
        noteField.tag = 1
        lunchField.tag = 2
    }
    func configureDaysCells() {
        for i in 0..<daysCells.count {
            daysCells[i].selectionStyle = .default
            daysCells[i].tintColor = Colors.darkerDetail
            
            if user.settings.overtime.getRules(forDay: Time.weekDays[i]).rules.isEmpty {
                daysCells[i].accessoryType = .disclosureIndicator
            } else {
                daysCells[i].accessoryType = .checkmark
            }
        }
    }
    func configureMinHoursField() {
        minHoursField.keyboardType = .decimalPad
        minHoursField.clearsOnBeginEditing = true
        minHoursField.inputAccessoryView = toolbar
        minHoursField.delegate = self
        minHoursField.tag = 5
        mySwitch.onTintColor = navColor
    }
    func configureTable() {
        tableView.tintColor = Colors.darkerDetail
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func populateWithSettings() {
        // Mininum hours
        minHoursField.text = String(user.settings.minimumHours)
        // Starting time
        startingTimePicker.date = user.settings.startingTime
        STField.text = Time.dateToTimeString(date: startingTimePicker.date)
        // Ending time
        endingTimePicker.date = user.settings.endingTime
        ETField.text = Time.dateToTimeString(date: endingTimePicker.date)
        // Note
        noteField.text = user.settings.title
        // Lunch
        lunchField.text = String(user.settings.breakTime)
        // Closing date
        if user.settings.newPeriod == 0 {
            autoTextField.text = "25th"
            autoTextField.textColor = .lightGray
            automaticallyLbl.textColor = .lightGray
            mySwitch.isOn = true
            picker.selectRow(24, inComponent: 0, animated: true)
        } else {
            automaticallyLbl.textColor = .black
            mySwitch.isOn = false
            autoTextField.text = String(user.settings.newPeriod)
            if [1, 21].contains(user.settings.newPeriod) {
                autoTextField.text! += "st"
            } else if [2, 22].contains(user.settings.newPeriod) {
                autoTextField.text! += "nd"
            } else if [3, 23].contains(user.settings.newPeriod) {
                autoTextField.text! += "rd"
            } else {
                autoTextField.text! += "th"
            }
            picker.selectRow(user.settings.newPeriod-1, inComponent: 0, animated: true)
        }
        autoTextField.text! += " day of month"
    }

    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else if section == 1 || section == 2 {
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 || section == 5{
            return 50
        } else {
            return 0
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 || section == 2{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
            let label = UILabel(frame: CGRect(x: 16, y: 10 + ((section == 0) ? 20 : 0), width: self.view.frame.width-32, height: 40))
            label.text = sectionTitles[section]
            label.font = UIFont.boldSystemFont(ofSize: 11)
            label.numberOfLines = 3
            label.sizeToFit()
            label.textColor = .black
            
            view.addSubview(label)
            
            return view
        }
        return UIView()
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 4 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            let label = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.width-32, height: 40))
            
            label.text = "Experienced something weird? Got any feedback or suggestions for improvements? Please consider sending us an email so that we can make this app better!"
            label.font = UIFont.systemFont(ofSize: 12, weight: .light)
            label.numberOfLines = 3
            label.sizeToFit()
            label.textColor = .gray
            
            view.addSubview(label)
            return view
        } else if section == 5 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            let label = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.width-32, height: 40))

            label.text = "If you like our app, leaving a review in the App Store will be very, very appreciated."
            label.font = UIFont.systemFont(ofSize: 12, weight: .light)
            label.numberOfLines = 3
            label.sizeToFit()
            label.textColor = .gray
            
            view.addSubview(label)
            return view
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 3 {
            let message = "Only change this setting if you sometimes work less hours than you actually get paid for. For example, changing this to 4 causes any shifts shorter than 4 hours to still be considered as 4 hours in length in calculations."
            let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        // Closing date detailbutton
        } else if indexPath.section == 2 {
            let message = "Turning this on enables you to manually choose which shift should be the beginning of a new period, regardless of the shifts date."
            let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            day = Time.weekDays[indexPath.row]
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
            sendEmail()
        } else {
            rateApp(appId: "id1312943979", completion: { success in
                print("RateApp \(success)")
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        if [1, 21].contains((row + 1)) {
            autoTextField.text = String(row + 1) + "st"
        } else if [2, 22].contains((row + 1)) {
            autoTextField.text = String(row + 1) + "nd"
        } else if [3, 23].contains((row + 1)) {
            autoTextField.text = String(row + 1) + "rd"
        } else {
            autoTextField.text = String(row + 1) + "th"
        }
        autoTextField.text! += " day of month"
        shiftsNeedsReOrganizing = true
    }
    
    @objc func datePickerDidEndEditing(sender: UIDatePicker) {
        if sender.tag == 1 {
            user.settings.startingTime = sender.date
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["starting": sender.date]])
        } else if sender.tag == 2{
            user.settings.endingTime = sender.date
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["ending": sender.date]])
        }
    }
    
    func createTimePicker() {
        startingTimePicker.datePickerMode = .time
        endingTimePicker.datePickerMode = .time
        startingTimePicker.addTarget(self, action: #selector(datePickerDidEndEditing(sender:)), for: .editingDidEnd)
        endingTimePicker.addTarget(self, action: #selector(datePickerDidEndEditing(sender:)), for: .editingDidEnd)
        startingTimePicker.addTarget(self, action: #selector(datePickerDidChangeValue(sender:)), for: .valueChanged)
        endingTimePicker.addTarget(self, action: #selector(datePickerDidChangeValue(sender:)), for: .valueChanged)
        startingTimePicker.tag = 1
        endingTimePicker.tag = 2
        
        ETField.inputAccessoryView = toolbar
        STField.inputAccessoryView = toolbar
        ETField.tintColor = UIColor.clear
        STField.tintColor = UIColor.clear
        ETField.inputView = endingTimePicker
        STField.inputView = startingTimePicker
        STField.delegate = self
        ETField.delegate = self
        STField.tag = 3
        ETField.tag = 4
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
