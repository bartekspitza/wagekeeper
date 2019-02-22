//
//  SettingsVC.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-19.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var navBar: UINavigationBar!
    
    // Textfields
    var taxrateField: UITextField!
    var wageRateField: UITextField!
    var currencyField: UITextField!

    // Pickers
    let currencyPicker = UIPickerView()
    let taxPicker = UIPickerView()
    
    
    var updateForm: UpdateForm!
    let currencies = ["SEK", "EUR", "GPD", "NOR", "USD"]
    
    var isUpdatingPassword = true
    var loadingIndicator: UIActivityIndicatorView!
    var updateMessageLbl: UILabel!
    var table: UITableView!
    
    // Displays account information
    var accountView: UIView!
    
    // Displays amount of shifts and the "compeleted shifts" after-text
    var shiftsLbl: UILabel!
    var amountShiftsLbl: UILabel!
    
    override func viewDidLoad() {
        self.title = "Account"
        self.navigationController?.navigationBar.tintColor = .black
        
        addAmountOfShiftsElement()
        addAccountView()
        addTable()
        configurePickers()
        addUpdatingForm()
        createUpdateMessageLabel()
        createLoadingIndicator()
    }
    
    func createUpdateMessageLabel() {
        updateMessageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        updateMessageLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        updateMessageLbl.text = "Logged in with"
        updateMessageLbl.textAlignment = .center
        updateMessageLbl.center = self.view.center
        updateMessageLbl.frame.origin.y = accountView.frame.origin.y + accountView.frame.height + 5
        updateMessageLbl.layer.opacity = 0
        self.view.addSubview(updateMessageLbl)
    }
    
    func createLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        loadingIndicator.center.x = self.view.center.x
        loadingIndicator.center.y = self.view.frame.height/2 + updateForm.formButton.center.y
        loadingIndicator.layer.zPosition = 2
        self.view.addSubview(loadingIndicator)
    }
    
    func addUpdatingForm() {
        updateForm = UpdateForm(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2))
        updateForm.addField1(isEmailField: true)
        updateForm.addField2(isEmailField: true)
        updateForm.addPasswordField()
        updateForm.addFormButton(title: "Update")
        updateForm.addBackButton()
        updateForm.center.x += self.view.frame.width
        updateForm.backButton.addTarget(self, action: #selector(hideForm), for: .touchUpInside)
        updateForm.formButton.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
        let toolbar = UIToolbar()
        let buttons = addButtons(bar: toolbar, withUpAndDown: false, color: .black)
        updateForm.field1.inputAccessoryView = toolbar
        updateForm.field2.inputAccessoryView = toolbar
        updateForm.passwordField.inputAccessoryView = toolbar
        buttons[0].action = #selector(donePressed)
        view.addSubview(updateForm)
    }
    
    @objc func hideForm() {
        updateForm.clear()
        updateForm.hideErrorMessage()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x += self.view.frame.width
            
            self.table.center.x += self.view.frame.width
        })
    }
    @objc func updatePressed() {
        if updateForm.field1.text == "" || updateForm.field2.text == ""  || updateForm.passwordField.text == "" {
            updateForm.showErrorMessage(message: "All fields must be entered")
        } else if updateForm.field1.text != updateForm.field2.text {
            updateForm.showErrorMessage(message: "Fields must match")
        } else {
            loadingIndicator.startAnimating()
            updateForm.formButton.setTitle("", for: .normal)
            if isUpdatingPassword {
                CloudAuth.login(email: user.email, password: updateForm.passwordField.text!, successHandler: { (result) in
                    CloudAuth.updatePassword(password: self.updateForm.field1.text!, successHandler: {
                        self.onFormOperationSuccess()
                    }, failureHandler: { (msg) in
                        self.onFormOperationFailure(msg: msg)
                    })
                }) { (msg) in
                    self.onFormOperationFailure(msg: msg)
                }
                
            } else {
                CloudAuth.login(email: user.email, password: updateForm.passwordField.text!, successHandler: { (result) in
                    CloudAuth.updateEmail(newEmail: self.updateForm.field1.text!, successHandler: {
                        self.onFormOperationSuccess()
                    }, failureHandler: { (msg) in
                        self.onFormOperationFailure(msg: msg)
                    })
                }) { (msg) in
                    self.onFormOperationFailure(msg: msg)
                }
            }
        }
    }
    
    @objc func showUpdateForm() {
        
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x -= self.view.frame.width
            
            self.table.center.x -= self.view.frame.width
        }) { (true) in
            self.table.deselectAllRows()
        }
    }
    
    func onFormOperationFailure(msg: String) {
        updateForm.showErrorMessage(message: msg)
        loadingIndicator.stopAnimating()
        updateForm.formButton.setTitle("Update", for: .normal)
    }
    func onFormOperationSuccess() {
        if isUpdatingPassword {
            showSuccessMessage(msg: "Updated password!")
        } else {
            updateForm.field1.text = user.email
            showSuccessMessage(msg: "Updated email!")
        }
        
        table.reloadData()
        loadingIndicator.stopAnimating()
        updateForm.formButton.setTitle("Update", for: .normal)
        hideForm()
    }
    func showSuccessMessage(msg: String) {
        updateMessageLbl.text = msg
        updateMessageLbl.layer.opacity = 1
        
        UIView.animate(withDuration: 3) {
            self.updateMessageLbl.layer.opacity = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        refreshAmountOfShifts()
    }
    
    func refreshAmountOfShifts() {
        amountShiftsLbl.text = Periods.totalShifts().description
        amountShiftsLbl.sizeToFit()
        
        amountShiftsLbl.center = CGPoint(x: self.view.center.x, y: self.view.frame.height/5)
        shiftsLbl.center.y = amountShiftsLbl.frame.origin.y + amountShiftsLbl.font.ascender - shiftsLbl.frame.height/2 + 5
        shiftsLbl.frame.origin.x = amountShiftsLbl.frame.origin.x + amountShiftsLbl.frame.width + 5
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        table.deselectAllRows()
    }
    
    func logOut() {
        Auth.auth().removeStateDidChangeListener(loginListener)
        CloudAuth.signOut()
        performSegue(withIdentifier: "goToAuth", sender: self)
        user = nil
        shiftToEdit = [0, 0]
        shifts = [[ShiftModel]]()
        shiftsNeedsReOrganizing = false
        periodsSeperatedByYear = [[[ShiftModel]]]()
        period = nil
        indexForChosenPeriod = [0, 0]
    }
    
    func addTable() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.height
        table = UITableView(frame: CGRect(x: 0, y: accountView.frame.origin.y + accountView.frame.height + 50, width: self.view.frame.width, height: self.view.frame.height*0.6 - tabBarHeight))
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.separatorColor = UIColor.black.withAlphaComponent(0.11)
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        self.view.addSubview(table)
    }
    
    func addAccountView() {
        accountView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        accountView.center.y = self.view.frame.height * 0.4
        let imageView = UIImageView(image: user.profileImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        imageView.frame.origin.x = 10
        imageView.center.y = 25
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        let nameLabel = UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.width-32, height: 40))
        nameLabel.text = "logged in with"
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        nameLabel.textColor = .gray
        nameLabel.textAlignment = .center
        
        let email = UILabel(frame: CGRect(x: 16, y: 15, width: self.view.frame.width-32, height: 40))
        email.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        email.textColor = .black
        email.textAlignment = .center
        email.text = user.email
        
        let separator = UIView(frame: CGRect(x: 0, y: 49, width: self.view.frame.width, height: 0.5))
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.11)
        let upperseparator = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        upperseparator.backgroundColor = UIColor.black.withAlphaComponent(0.11)
        
        if user.loggedInWithFacebook {
            accountView.addSubview(imageView)
            nameLabel.frame.origin.x = imageView.frame.origin.x + 40 + 10
            nameLabel.textAlignment = .left
            nameLabel.text = user.firstName + " " + user.lastName
            nameLabel.textColor = .black
            nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            email.frame.origin.x = imageView.frame.origin.x + 40 + 10
            email.textAlignment = .left
            email.font = UIFont.systemFont(ofSize: 14, weight: .light)
        }
        
        accountView.addSubview(nameLabel)
        accountView.addSubview(email)
        accountView.addSubview(separator)
        accountView.addSubview(upperseparator)
        self.view.addSubview(accountView)
    }
    
    func addAmountOfShiftsElement() {
        //let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let shiftsAmountView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.4))
        
        amountShiftsLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        amountShiftsLbl.font = UIFont.systemFont(ofSize: 60, weight: .light)
        amountShiftsLbl.text = Periods.totalShifts().description
        amountShiftsLbl.textAlignment = .center
        amountShiftsLbl.textColor = .black
        amountShiftsLbl.sizeToFit()
        amountShiftsLbl.center = CGPoint(x: self.view.center.x, y: shiftsAmountView.frame.height/2)
        
        shiftsLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        shiftsLbl.font = UIFont.systemFont(ofSize: 12, weight: .light)
        shiftsLbl.text = "completed shifts"
        shiftsLbl.textColor = .gray
        shiftsLbl.sizeToFit()
        shiftsLbl.center.y = amountShiftsLbl.frame.origin.y + amountShiftsLbl.font.ascender - shiftsLbl.frame.height/2 + 5
        shiftsLbl.frame.origin.x = amountShiftsLbl.frame.origin.x + amountShiftsLbl.frame.width + 5

        shiftsAmountView.center.y = self.view.frame.height/4 //+ navigationBarHeight
        shiftsAmountView.addSubview(shiftsLbl)
        shiftsAmountView.addSubview(amountShiftsLbl)
        self.view.addSubview(shiftsAmountView)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        Periods.makePeriod(yearIndex: indexForChosenPeriod[0], monthIndex: indexForChosenPeriod[1], successHandler: {})
        if textField.tag == 1 {
            if textField.text == "" {
                textField.text = "0"
            }
            
            UserDefaults().set(textField.text!, forKey: "wageRate")
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width:
            tableView.bounds.size.width, height: 30))
        headerLabel.font = UIFont.boldSystemFont(ofSize: 10)
        headerLabel.text = ["App settings", "Account"][section]
        headerLabel.center.y = 15
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            if user.loggedInWithFacebook {
                return 1
            }
            return 3
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                taxrateField.becomeFirstResponder()
            } else if indexPath.row == 1 {
                wageRateField.becomeFirstResponder()
            } else if indexPath.row == 2 {
                currencyField.becomeFirstResponder()
            } else {
                performSegue(withIdentifier: "advancedtools", sender: self)
            }
        } else {
            if user.loggedInWithFacebook {
                logOut()
            } else {
                if indexPath.row == 0 {
                    isUpdatingPassword = false
                    updateForm.field1.placeholder = "New email"
                    updateForm.field2.placeholder = "Confirm email"
                    showUpdateForm()
                } else if indexPath.row == 1 {
                    isUpdatingPassword = true
                    updateForm.field1.placeholder = "New password"
                    updateForm.field2.placeholder = "Confirm password"
                    showUpdateForm()
                } else {
                    logOut()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let imageNames = [
            ["taxIcon.png", "wageIcon2", "currencyicon.png", "toolicon.png"],
            (user.loggedInWithFacebook) ? ["account"] : ["email_icon", "key_icon", "account"]
        ]
        
        let titles = [
            ["Tax rate", "Hourly wage", "Currency", "Advanced tools"],
            (user.loggedInWithFacebook) ? ["Log out"] : ["Change email", "Change password", "Log out"]
        ]
        
        let image = UIImage(named: imageNames[indexPath.section][indexPath.row])
   
        cell?.textLabel?.text = titles[indexPath.section][indexPath.row]
        
        let imageView = UIImageView(image: image)
        imageView.setImageColor(color: .black)
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.center = CGPoint(x: 25, y: (cell?.frame.height)!/2)
        cell?.contentView.addSubview(imageView)
        cell?.indentationLevel = 5
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        if (indexPath.section == 0 && indexPath.row < 3) {
            cell?.selectionStyle = .none
            let field = UITextField()
            field.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            field.frame.origin.x = self.view.frame.width - 15 - field.frame.width
            field.textAlignment = .right
            if indexPath.row == 0 {
                taxrateField = field
            } else if indexPath.row == 1 {
                wageRateField = field
            } else {
                currencyField = field
                configureFields()
                loadUserDefaults()
            }
            cell?.contentView.addSubview(field)
        }
        
        return cell!
    }
    
    func configurePickers() {
        taxPicker.tag = 1
        taxPicker.delegate = self
        taxPicker.dataSource = self
        
        currencyPicker.tag = 2
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }
    
    func configureFields() {
        let toolbar = UIToolbar()
        let buttons = toolbar.addButtons(withUpAndDown: false, color: .black)
        buttons[0].action = #selector(donePressed)
        taxrateField.tintColor = .clear
        taxrateField.inputView = taxPicker
        taxrateField.inputAccessoryView = toolbar
        taxrateField.textColor = .black
        taxrateField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        taxrateField.delegate = self
        
        wageRateField.clearsOnBeginEditing = true
        wageRateField.inputAccessoryView = toolbar
        wageRateField.keyboardType = .decimalPad
        wageRateField.textColor = .black
        wageRateField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        wageRateField.delegate = self
        wageRateField.tag = 1
        
        currencyField.tintColor = UIColor.clear
        currencyField.inputAccessoryView = toolbar
        currencyField.inputView = currencyPicker
        currencyField.textColor = .black
        currencyField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        currencyField.delegate = self
    }
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
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
        if pickerView.tag == 1 {
            return 3
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
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
        if pickerView.tag == 1 {
            if component == 0 {
                return 101
            } else if component == 2 {
                return 10
            } else {
                return 1
            }
        }
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
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
            UserDefaults().set(taxString, forKey: "taxRate")
            
        } else {
            currencyField.text = currencies[row]
            UserDefaults().set(currencyField.text!, forKey: "currency")
        }
    }
    func createTaxString(part1: String, part2: String) -> String {
        var returnString = ""
        returnString = part1 + "." + part2 + " %"
        return returnString
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
}
