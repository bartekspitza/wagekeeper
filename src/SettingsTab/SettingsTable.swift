//
//  SettingsTable.swift
//  adding shifts
//
//  Created by Bartek  on 2017-10-27.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class SettingsTable: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let titles = ["TAX", "WAGE", "GENERAL"]
    
    // Other
    let currencyPicker = UIPickerView()
    let taxPicker = UIPickerView()
    let currencies = ["SEK", "EUR", "GPD", "NOR", "USD"]
    
    
    // Cell labels
    @IBOutlet weak var taxRateLbl: UILabel!
    @IBOutlet weak var hourlyWageLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var advancedSettingsLbl: UILabel!
    
    // Cell icons
    @IBOutlet weak var taxIcon: UIImageView!
    @IBOutlet weak var wageIcon: UIImageView!
    @IBOutlet weak var currencyIcon: UIImageView!
    @IBOutlet weak var toolIcon: UIImageView!
    
    // Textfields
    @IBOutlet weak var taxrateField: UITextField!
    @IBOutlet weak var wageRateField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    
    // Toolbar
    let toolbar = UIToolbar()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
    
    var currentField = 0
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        tableView.tintColor = navColor
        myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.width, height: 1))
        myTableView.separatorStyle = .none

        
        iconColor(color: navColor.withAlphaComponent(0.85))
        createCurrencyPicker()
        createTaxPicker()
        createWageField()
        designCellLabels()
        loadUserDefaults()
    }
    
    func iconColor(color: UIColor) {
        let icons = [taxIcon, wageIcon, currencyIcon, toolIcon]
        for icon in icons {
            icon!.image = icon!.image!.withRenderingMode(.alwaysTemplate)
            icon!.tintColor = color
        }
    }
    
    func designCellLabels() {
        taxRateLbl.textColor = navColor
        hourlyWageLbl.textColor = navColor
        currencyLbl.textColor = navColor
        advancedSettingsLbl.textColor = navColor
    }
    
    func createTableBackground() {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [navColor.cgColor, headerColor.withAlphaComponent(0.3).cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let startingLocation = NSNumber(floatLiteral: Double(Double(66)/Double(gradientLayer.frame.height)))
        gradientLayer.locations = [startingLocation, 1.0]

        let view = UIView(frame: CGRect(x: 0, y: 66, width: self.view.frame.width, height: self.view.frame.height))
        view.layer.addSublayer(gradientLayer)
        myTableView.backgroundView = view
    }
    
    
    func loadUserDefaults() {
        // TAX
        let taxRate = UserDefaults().string(forKey: "taxRate")!
        taxrateField.text = taxRate + " %"
        taxPicker.selectRow(Int(Float(taxRate)!), inComponent: 0, animated: true)
        taxPicker.selectRow(Int(String(Array(taxRate)[(taxRate.count)-1]))!, inComponent: 2, animated: true)
        
        // WAGE
        wageRateField.text = UserDefaults().string(forKey: "wageRate")
        
        // CURRENCY
        currencyField.text = UserDefaults().string(forKey: "currency")
        currencyPicker.selectRow(currencies.index(of: currencyField.text!)!, inComponent: 0, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            taxrateField.becomeFirstResponder()
        } else if indexPath.row == 1 {
            wageRateField.becomeFirstResponder()
        } else if indexPath.row == 2 {
            currencyField.becomeFirstResponder()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = headerColor
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 15, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.boldSystemFont(ofSize: 10)
        headerLabel.textColor = textColor
        headerLabel.text = titles[section]
        headerLabel.sizeToFit()
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    

    @IBAction func baseTaxRateSet(_ sender: UITextField) {
        let taxString = String(Array(taxrateField.text!)[0..<taxrateField.text!.count-2])
        UserDefaults().set(taxString, forKey: "taxRate")
        
    }
    
    @IBAction func wageSet(_ sender: UITextField) {
        if wageRateField.text != "" {
            UserDefaults().set(wageRateField.text!.floatValue, forKey: "wageRate")
        } else {
            wageRateField.text = "0"
            UserDefaults().set(wageRateField.text!.floatValue, forKey: "wageRate")
        }
    }
    
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    // CurrencyPicker TaxPicker
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView.tag == 2 {
            if component == 1 {
                return 15
            } else {
                return 50
            }
        } else {
            return 60
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 2 {
            return 3
        } else {
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 2 {
            if component == 0 {
                return String([Int](0...100)[row])
            } else if component == 2{
                return String([Int](0...9)[row])
            } else {
                return "."
            }
        } else {
            return currencies[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 2 {
            if component == 0 {
                return 101
            } else if component == 2 {
                return 10
            } else {
                return 1
            }
        } else {
            return currencies.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 2 {
            // Disables values like 100.1, 100.2 etc..
            if pickerView.selectedRow(inComponent: 0) == 100 && pickerView.selectedRow(inComponent: 2) != 0 {
                pickerView.selectRow(0, inComponent: 2, animated: true)
            }
            
            let part1Value = pickerView.selectedRow(inComponent: 0)
            let part2Value = pickerView.selectedRow(inComponent: 2)

            let integerArray = [Int](0...100)
            let decimalArray = [Int](0...10)
            
            taxrateField.text = createTaxString(part1: String(integerArray[part1Value]), part2: String(decimalArray[part2Value]))
            let taxString = String(Array(taxrateField.text!)[0..<taxrateField.text!.count-2])
            UserDefaults().set(taxString, forKey: "baseTaxRate")
            
        } else {
            currencyField.text = currencies[row]
            UserDefaults().set(currencyField.text!, forKey: "currency")
        }
    }
    
    
    @IBAction func taxFieldPressed(_ sender: UITextField) {currentField = 0}
    @IBAction func wageFieldPressed(_ sender: UITextField) {currentField = 1}
    @IBAction func currencyFieldPressed(_ sender: UITextField) {currentField = 2}
    
    @objc func prevField(sender: UIBarButtonItem) {
        if currentField == 1 {
            taxrateField.becomeFirstResponder()
        } else if currentField == 2 {
            wageRateField.becomeFirstResponder()
        }
    }
    @objc func nextField(sender: UIBarButtonItem) {
        if currentField == 0 {
            wageRateField.becomeFirstResponder()
        } else if currentField == 1 {
            currencyField.becomeFirstResponder()
        }
    }
    
    func createTaxString(part1: String, part2: String) -> String {
        var returnString = ""
        returnString = part1 + "." + part2 + " %"
        return returnString
    }
    
    // Create Fields
    func createCurrencyPicker() {
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

        currencyPicker.tag = 1
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        currencyField.tintColor = UIColor.clear
        currencyField.inputAccessoryView = toolbar
        currencyField.inputView = currencyPicker
        currencyField.textColor = navColor
    }
    
    func createTaxPicker() {
        taxrateField.tintColor = .clear
        taxPicker.delegate = self
        taxPicker.dataSource = self
        taxPicker.tag = 2
        taxrateField.inputView = taxPicker
        taxrateField.inputAccessoryView = toolbar
        taxrateField.textColor = navColor
    }
    
    func createWageField() {
        wageRateField.clearsOnBeginEditing = true
        wageRateField.inputAccessoryView = toolbar
        wageRateField.keyboardType = .decimalPad
        wageRateField.textColor = navColor
    }
}

