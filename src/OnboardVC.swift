//
//  OnboardVC.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-28.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class OnboardVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var wageField: UITextField!
    @IBOutlet weak var taxField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    let taxPicker = UIPickerView()
    let currencyPicker = UIPickerView()
    let currencies = ["SEK", "EUR", "GPD", "NOR", "USD"]
    
    var fieldsFilled = [false, false, false, false]
    var floatUsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLbl.alpha = 0
        jobField.alpha = 0
        wageField.alpha = 0
        taxField.alpha = 0
        currencyField.alpha = 0
        designLabels()
        designFields()
        designFieldPickers()
        makeGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animations()
    }

    func animations() {
        UIView.animate(withDuration: 0.5) {
            self.welcomeLbl.alpha = 1
        }
        UIView.animate(withDuration: 0.7) {
            self.jobField.alpha = 1
        }
        UIView.animate(withDuration: 0.9) {
            self.wageField.alpha = 1
        }
        UIView.animate(withDuration: 1.1) {
            self.taxField.alpha = 1
        }
        UIView.animate(withDuration: 1.3) {
            self.currencyField.alpha = 1
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func makeGradient() {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [navColor.cgColor, headerColor.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    func designFieldPickers() {
        taxPicker.delegate = self
        taxPicker.dataSource = self
        taxPicker.tag = 1
        taxPicker.backgroundColor = .darkGray
        taxPicker.tintColor = .white
        
        taxField.layer.zPosition = 2
        taxField.inputView = taxPicker
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        currencyPicker.tag = 2
        currencyPicker.backgroundColor = .darkGray
        currencyPicker.tintColor = .white
        
        currencyField.layer.zPosition = 2
        currencyField.inputView = currencyPicker
    }
    
    
    @IBAction func doneTapped(_ sender: UIButton) {
        if fieldsFilled.contains(false) {
            sender.shake(direction: "horizontal", swings: 2)
        } else {
            performSegue(withIdentifier: "gotoapp", sender: self)
        }
    }
    
    func designLabels() {
        welcomeLbl.textColor = .white
        welcomeLbl.layer.zPosition = 2
        welcomeLbl.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.1))
    }
    
    func designFields() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        let flexSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolbar.sizeToFit()
        toolbar.setItems([flexSpace1, doneButton], animated: false)
        toolbar.barTintColor = UIColor.darkGray
        doneButton.tintColor = .white
        
        
        doneBtn.layer.zPosition = 2
        doneBtn.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.65))
        doneBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: UIControlState.normal)
        
        jobField.layer.zPosition = 2
        jobField.backgroundColor = UIColor.clear
        jobField.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/2), height: Int(50))
        jobField.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.25))
        jobField.textColor = .white
        jobField.attributedPlaceholder = NSAttributedString(string: "JOB NAME", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.4), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        jobField.borderStyle = .roundedRect
        jobField.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        jobField.layer.borderWidth = 1.0
        jobField.tintColor = .white
        jobField.inputAccessoryView = toolbar
        jobField.keyboardAppearance = .dark
        jobField.autocapitalizationType = .sentences
        jobField.layer.cornerRadius = 10
        
        wageField.layer.zPosition = 2
        wageField.backgroundColor = UIColor.clear
        wageField.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/2), height: 50)
        wageField.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.35))
        wageField.textColor = .white
        wageField.attributedPlaceholder = NSAttributedString(string: "HOURLY WAGE", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.4), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        wageField.borderStyle = .roundedRect
        wageField.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        wageField.layer.borderWidth = 1.0
        wageField.tintColor = .white
        wageField.inputAccessoryView = toolbar
        wageField.keyboardAppearance = .dark
        wageField.keyboardType = .decimalPad
        wageField.layer.cornerRadius = 10
        
        taxField.layer.zPosition = 2
        taxField.backgroundColor = UIColor.clear
        taxField.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/2), height: Int(50))
        taxField.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.45))
        taxField.textColor = .white
        taxField.attributedPlaceholder = NSAttributedString(string: "TAX RATE", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.4), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        taxField.borderStyle = .roundedRect
        taxField.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        taxField.layer.borderWidth = 1.0
        taxField.tintColor = .clear
        taxField.inputAccessoryView = toolbar
        taxField.layer.cornerRadius = 10
        
        currencyField.layer.zPosition = 2
        currencyField.backgroundColor = UIColor.clear
        currencyField.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/2), height: Int(50))
        currencyField.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.55))
        currencyField.textColor = .white
        currencyField.attributedPlaceholder = NSAttributedString(string: "CURRENCY", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.4), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        currencyField.borderStyle = .roundedRect
        currencyField.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        currencyField.layer.borderWidth = 1.0
        currencyField.tintColor = .clear
        currencyField.inputAccessoryView = toolbar
        currencyField.layer.cornerRadius = 10
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func jobChanged(_ sender: UITextField) {
        if jobField.text == "" {
            fieldsFilled[0] = false
        } else {
            fieldsFilled[0] = true
        }
        
        if !fieldsFilled.contains(false) {
            doneBtn.setTitleColor(.white, for: UIControlState.normal)
        } else {
            doneBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: UIControlState.normal)
        }
    }
    
    
    @IBAction func wage(_ sender: UITextField) {
        var character: String?
        if wageField.text!.count > 0 {
            character = Array(wageField.text!).last?.description
        }
            
            
        if ((wageField.text?.contains(","))! || (wageField.text?.contains("."))!) && (character == "," || character == ".") && floatUsed {
            wageField.text = String(Array(wageField.text!)[0..<wageField.text!.count-1])
        }
        
        if ((wageField.text?.contains(","))! || (wageField.text?.contains("."))!) {
            floatUsed = true
        } else {
            floatUsed = false
        }
        
        
        if wageField.text == "" {
            fieldsFilled[1] = false
        } else {
            fieldsFilled[1] = true
        }
        
        if !fieldsFilled.contains(false) {
            doneBtn.setTitleColor(.white, for: UIControlState.normal)
        } else {
            doneBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: UIControlState.normal)
        }
    }
    
    @IBAction func taxPressed(_ sender: UITextField) {
        if taxField.text == "" {
            taxField.text = "0.0 %"
            fieldsFilled[2] = true
        }
        
        if !fieldsFilled.contains(false) {
            doneBtn.setTitleColor(.white, for: UIControlState.normal)
        } else {
            doneBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: UIControlState.normal)
        }
    }
    
    @IBAction func currencyPressed(_ sender: UITextField) {
        if currencyField.text == "" {
            currencyField.text = currencies.first
            fieldsFilled[3] = true
        }
        
        if !fieldsFilled.contains(false) {
            doneBtn.setTitleColor(.white, for: UIControlState.normal)
        } else {
            doneBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: UIControlState.normal)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView.tag == 1 {
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
        if pickerView.tag == 1 {
            return 3
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            if component == 0 {
                return String([Int](0...100)[row])
            } else if component == 2{
                return String([Int](0...9)[row])
            } else {
                return "hey"
            }
        } else {
            return "hey"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView.tag == 1 {
            var titleData = row.description
            if pickerView.tag == 1 && component == 1 {
                titleData = "."
            }
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 15.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
            return myTitle
        } else {
            let titleData = currencies[row]

            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 15.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
            return myTitle
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            if pickerView.selectedRow(inComponent: 0) == 100 && pickerView.selectedRow(inComponent: 2) != 0 {
                pickerView.selectRow(0, inComponent: 2, animated: true)
            }
            
            let part1Value = pickerView.selectedRow(inComponent: 0)
            let part2Value = pickerView.selectedRow(inComponent: 2)
            
            let integerArray = [Int](0...100)
            let decimalArray = [Int](0...10)
            
            taxField.text = createTaxString(part1: String(integerArray[part1Value]), part2: String(decimalArray[part2Value]))
        } else {
            currencyField.text = currencies[pickerView.selectedRow(inComponent: 0)]
        }
    }
    
    func createTaxString(part1: String, part2: String) -> String {
        var returnString = ""
        returnString = part1 + "." + part2 + " %"
        return returnString
    }
}
