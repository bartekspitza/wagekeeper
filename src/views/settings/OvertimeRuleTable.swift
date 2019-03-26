//
//  OvertimeRuleTable.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-06.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit


var day = ""

class OvertimeRuleTable: UITableViewController, UITextFieldDelegate {
    
    let timePicker = UIDatePicker()
    var sectionFlag = 0
    var startFocused = Bool()
    
    var rateFields = [UITextField]()
    var ends = [[Any]]()
    var starts = [[Any]]()
    
    @IBOutlet var myTableView: UITableView!
    
    var rules: [OvertimeRule]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .black
        let rightBtn = UIBarButtonItem(title: "Add rule", style: .plain, target: self, action: #selector(addRulePressed))
        self.navigationItem.rightBarButtonItem = rightBtn
        self.navigationItem.title = day
        self.hideKeyboardWhenTappedAround()
        configureTable()
        configureTimePicker()
        rules = user.settings.overtime.getRules(forDay: day).rules
        loadRules()
        
        if rules.isEmpty {
            addRulePressed()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            var indxCount = 0
            while (indxCount != starts.count) {
                if rateFields[indxCount].text == "" || (starts[indxCount][0] as! UITextField).text == "" || (ends[indxCount][0] as! UITextField).text == "" || (ends[indxCount][1] as! Date) < (starts[indxCount][1] as! Date) {
                    rateFields.remove(at: indxCount)
                    starts.remove(at: indxCount)
                    ends.remove(at: indxCount)
                } else {
                    indxCount += 1
                }
            }
            
            var rules = [OvertimeRule]()
            
            for i in 0..<starts.count {
                let start = starts[i][1] as! Date
                let end = ends[i][1] as! Date
                
                let rate = Float(rateFields[i].text!)!
                let rule = OvertimeRule(starting: start, ending: end, rate: rate)
                rules.append(rule)
            }
            
            let newDay = OvertimeDay(day: day, rules: rules)
            let shouldUpdate = user.settings.overtime.isDayDifferent(day: newDay)
            
            if shouldUpdate {
                shiftsNeedsReOrganizing = true
                user.settings.overtime.update(day: newDay)
                CloudStorage.updateOvertime(toUser: user.ID, obj: ["settings": ["overtime": user.settings.overtime.json()]])
            }
        }
    }
    
    func loadRules() {
        for rule in rules {
            let startField = UITextField()
            startField.font = UIFont.systemFont(ofSize: 15, weight: .light)
            startField.borderStyle = .none
            startField.textAlignment = .right
            startField.addTarget(self, action: #selector(STPressed), for: UIControl.Event.editingDidBegin)
            startField.inputView = timePicker
            startField.tintColor = UIColor.clear
            startField.text = Time.dateToTimeString(date: rule.starting) + "   -"
            
            starts.append([startField, rule.starting])
            
            let endField = UITextField()
            endField.font = UIFont.systemFont(ofSize: 15, weight: .light)
            endField.borderStyle = .none
            endField.textAlignment = .right
            endField.addTarget(self, action: #selector(ETPressed), for: UIControl.Event.editingDidBegin)
            endField.inputView = timePicker
            endField.tintColor = UIColor.clear
            endField.text = Time.dateToTimeString(date: rule.ending)
            ends.append([endField, rule.ending])
            
            let field = UITextField()
            field.keyboardType = .decimalPad
            field.clearsOnBeginEditing = true
            field.textAlignment = .right
            field.borderStyle = .none
            field.delegate = self
            field.font = UIFont.systemFont(ofSize: 15, weight: .light)
            field.attributedPlaceholder = NSAttributedString(string:"for this interval", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .light)])
            field.text = Float(rule.rate).round(decimals: 2).description
            rateFields.append(field)
        }
    }
    
    func configureTimePicker() {
        timePicker.addTarget(self, action: #selector(timePickerChanged), for: UIControl.Event.valueChanged)
        timePicker.datePickerMode = .time
    }
    
    
    func configureTable() {
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.myTableView.separatorColor = UIColor.black.withAlphaComponent(0.11)
        self.myTableView.backgroundColor = .white
    }
    
    @objc func addRulePressed() {
        let endField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/7, height: 20))
        endField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        endField.borderStyle = .none
        endField.textAlignment = .right
        endField.addTarget(self, action: #selector(ETPressed), for: UIControl.Event.editingDidBegin)
        endField.inputView = timePicker
        endField.tintColor = UIColor.clear
        endField.text = "  " + Time.dateToTimeString(date: startDate())
        ends.append([endField, startDate()])

        
        let startField = UITextField(frame: CGRect(x: 0, y: 0, width: (self.view.frame.width/7), height: 20))
        startField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        startField.borderStyle = .none
        startField.textAlignment = .right
        startField.addTarget(self, action: #selector(STPressed), for: UIControl.Event.editingDidBegin)
        startField.inputView = timePicker
        startField.tintColor = UIColor.clear
        var date = startDate()
        if !starts.isEmpty {
            date = ends[ends.count-2][1] as! Date
        }
        starts.append([startField, date])
        startField.text = Time.dateToTimeString(date: date) + "   -"
        
        let rateField = UITextField(frame: CGRect(x: 0, y: 0, width: (self.view.frame.width/2), height: 20))
        rateField.keyboardType = .decimalPad
        rateField.clearsOnBeginEditing = true
        rateField.textAlignment = .right
        rateField.borderStyle = .none
        rateField.delegate = self
        rateField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        rateField.attributedPlaceholder = NSAttributedString(string:"for this interval", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .light)])
        rateFields.append(rateField)
        
        let indexSet = NSMutableIndexSet()
        indexSet.add(starts.count-1)
        myTableView.insertSections(indexSet as IndexSet, with: UITableView.RowAnimation.fade)
        
        myTableView.reloadData()
    }
    
    func startDate() -> Date {
        return Date(timeIntervalSinceReferenceDate: 0)
    }
       
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == starts.count-1{
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            let label = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.width-32, height: 40))
            
            label.text = "For accurate salary calculations, make sure intervals are not overlapping each other."
            label.font = UIFont.systemFont(ofSize: 12, weight: .light)
            label.numberOfLines = 3
            label.sizeToFit()
            label.textColor = .gray
            
            view.addSubview(label)
            return view
    
        }
        return UIView()
    }
    
    @objc func timePickerChanged(sender: UIDatePicker) {
        if startFocused {
            
            starts[sectionFlag][1] = sender.date
            (starts[sectionFlag][0] as! UITextField).text = Time.dateToTimeString(date: starts[sectionFlag][1] as! Date) + "   -"
            
            // Handling endField date
            if (ends[sectionFlag][0] as! UITextField).text == "" {
                ends[sectionFlag][1] = createNextTime(date: sender.date)
            }
            
        } else {
            ends[sectionFlag][1] = sender.date
            (ends[sectionFlag][0] as! UITextField).text = "  " + Time.dateToTimeString(date: sender.date)
        }
    }
    
    @objc func ETPressed(_ sender: UITextField) {
        sectionFlag = sender.tag

        startFocused = false
        timePicker.date = ends[sectionFlag][1] as! Date
    }
    @objc func STPressed(_ sender: UITextField) {
        // Keeping track of which section we are in
        sectionFlag = sender.tag
        startFocused = true
        timePicker.date = starts[sectionFlag][1] as! Date
        
        if sender.text == "" {
            sender.text = Time.dateToTimeString(date: starts[sectionFlag][1] as! Date)
            if (ends[sectionFlag][0] as! UITextField).text == "" {
                ends[sectionFlag][1] = createNextTime(date: starts[sectionFlag][1] as! Date)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            textField.text = Float(textField.text!)!.round(decimals: 2).description
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        // Interval Cell
        if indexPath.row == 0 {

            let endRateField = ends[indexPath.section][0] as! UITextField
            let text = Time.dateToTimeString(date: Time.beginningOfDay())
            let width = (text + "  ").sizeOfString(usingFont: endRateField.font!).width

            endRateField.tag = indexPath.section
            endRateField.frame = CGRect(x: self.view.frame.width - width - 15, y: 0, width: width+1, height: cell.frame.height)
            
            let startRateField = starts[indexPath.section][0] as! UITextField
            startRateField.tag = indexPath.section
            startRateField.frame = CGRect(x: endRateField.frame.origin.x - 150, y: 0, width: 150, height: cell.frame.height)
            cell.addSubview(endRateField)
            cell.addSubview(startRateField)
            
            cell.textLabel?.text = "Interval"
            // Rate Cell
        } else {
            rateFields[indexPath.section].frame = CGRect(x: self.view.frame.width - 115, y: 0, width: 100, height: cell.frame.height)
            rateFields[indexPath.section].tag = indexPath.section
            
            cell.addSubview(rateFields[indexPath.section])
            cell.textLabel?.text = "Hourly wage"
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .light)
        return cell
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == starts.count-1 {
            return 40
        } else {
            return 0.1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        let label = UILabel(frame: CGRect(x: 16, y: 20, width: self.view.frame.width-32, height: 40))
        label.text = "Rule " + (section + 1).description
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.numberOfLines = 3
        label.sizeToFit()
        label.textColor = .black
        
        view.addSubview(label)
        
        return view
    }
    
    
    func createNextTime(date: Date) -> Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: date)!
    }
    
    func createBeforeTime(date: Date) -> Date {
        return Calendar.current.date(byAdding: .minute, value: -1, to: date)!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return starts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction()
        
        delete.title = "Delete"
        delete.backgroundColor = UIColor.gray
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete")   { (_ rowAction: UITableViewRowAction, _ indexPath: IndexPath) in
            
            if indexPath.section == self.starts.count-1 {
                self.navigationItem.rightBarButtonItem?.tintColor = .black
                
            }
            
            if !(indexPath.section == self.starts.count-1) { // If element is not the last one in the arrays
                for section in self.starts[indexPath.section+1..<self.starts.count] {
                    (section[0] as! UITextField).tag -= 1
                }
                for section in self.ends[indexPath.section..<self.ends.count] {
                    (section[0] as! UITextField).tag -= 1
                }
            }
            
            self.rateFields.remove(at: indexPath.section)
            self.starts.remove(at: indexPath.section)
            self.ends.remove(at: indexPath.section)
            self.myTableView.deleteSections([indexPath.section], with: UITableView.RowAnimation.fade)
            self.myTableView.reloadData()
            
        }
        deleteAction.backgroundColor = UIColor.gray
        return [deleteAction]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            rateFields[indexPath.section].becomeFirstResponder()
        }
    }
}
