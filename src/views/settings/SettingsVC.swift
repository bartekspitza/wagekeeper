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
    var taxrateField = UITextField()
    var wageRateField = UITextField()
    var currencyField = UITextField()

    // Pickers
    let currencyPicker = UIPickerView()
    let taxPicker = UIPickerView()
    
    var updateForm: UpdateForm!
    let currencies = ["SEK", "EUR", "GPD", "NOR", "USD"]
    var cellsAreBuilt = [[Bool]]()
    
    var isUpdatingPassword = true
    var updateMessageLbl: UILabel!
    var table: UITableView!
    
    // Displays account information
    var accountView: UIView!
    
    // Displays amount of shifts and the "compeleted shifts" after-text
    var amountShiftsView: UIView!
    var shiftsLbl: UILabel!
    var amountShiftsLbl: UILabel!
    
    override func viewDidLoad() {
        configureView()
        hideNavBarSeparator()
        addAccountView()
        addAmountOfShiftsElement()
        addTable()
        configurePickers()
        addUpdatingForm()
        createUpdateMessageLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshAmountOfShifts()
        populateWithSettings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismissKeyboard()
    }
    
    func createUpdateMessageLabel() {
        updateMessageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        updateMessageLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        updateMessageLbl.text = "Logged in with"
        updateMessageLbl.textAlignment = .center
        updateMessageLbl.frame.origin.y = accountView.endY() + 5
        updateMessageLbl.center.x = self.view.center.x
        updateMessageLbl.layer.opacity = 0
        self.view.addSubview(updateMessageLbl)
    }
    
    func addUpdatingForm() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.height
        updateForm = UpdateForm(frame: CGRect(x: 0, y: self.view.frame.height*0.4, width: self.view.frame.width, height: self.view.frame.height*0.6 - tabBarHeight!))
        updateForm.addField1(isEmailField: true)
        updateForm.addField2(isEmailField: true)
        updateForm.addPasswordField()
        updateForm.addFormButton(title: "Update")
        updateForm.addBackButton()
        updateForm.center.x += self.view.frame.width
        updateForm.backButton.addTarget(self, action: #selector(hideForm), for: .touchUpInside)
        updateForm.formButton.button.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
        updateForm.field1.delegate = self
        updateForm.field2.delegate = self
        updateForm.passwordField.delegate = self
        view.addSubview(updateForm)
    }

    @objc func hideForm() {
        updateForm.clear()
        updateForm.hideErrorMessage()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x += self.view.frame.width
            self.amountShiftsView.center.x += self.view.frame.width
            self.table.center.x += self.view.frame.width
        })
    }
    @objc func updatePressed() {
        if updateForm.field1.text == "" || updateForm.field2.text == ""  || updateForm.passwordField.text == "" {
            updateForm.showErrorMessage(message: "All fields must be entered")
        } else if updateForm.field1.text != updateForm.field2.text {
            updateForm.showErrorMessage(message: "Fields must match")
        } else {
            updateForm.formButton.startAnimating()
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
            self.amountShiftsView.center.x -= self.view.frame.width
            self.table.center.x -= self.view.frame.width
        }) { (true) in
            self.table.deselectAllRows()
        }
    }
    
    func onFormOperationFailure(msg: String) {
        updateForm.showErrorMessage(message: msg)
        updateForm.formButton.stopAnimating(newTitle: nil)
    }
    func onFormOperationSuccess() {
        if isUpdatingPassword {
            showSuccessMessage(msg: "Updated password!")
        } else {
            user.email = updateForm.field1.text!
            showSuccessMessage(msg: "Updated email!")
            addAccountView()
        }
        
        updateForm.formButton.stopAnimating(newTitle: nil)
        hideForm()
    }
    func showSuccessMessage(msg: String) {
        updateMessageLbl.text = msg
        updateMessageLbl.layer.opacity = 1
        updateMessageLbl.textColor = Colors.success
        UIView.animate(withDuration: 3) {
            self.updateMessageLbl.layer.opacity = 0
        }
    }
    
    
    func refreshAmountOfShifts() {
        amountShiftsLbl.text = Periods.totalShifts().description
        let textSize = amountShiftsLbl.text?.sizeOfString(usingFont: amountShiftsLbl.font)
        amountShiftsLbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: textSize!.height)
        
        let spaceBetweenAccountViewAndMenu = table.frame.origin.y - accountView.endY()
        amountShiftsView.center.y = accountView.endY() + spaceBetweenAccountViewAndMenu/2
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
        loginViewShouldAnimate = true
    }
    
    func addTable() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.height
        table = UITableView(frame: CGRect(x: 0, y: self.view.frame.height*0.4 + 1, width: self.view.frame.width, height: self.view.frame.height*0.6 - tabBarHeight!))
        table.delegate = self
        table.dataSource = self
        table.register(SettingsCell.self, forCellReuseIdentifier: "cell")
        table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.separatorColor = UIColor.black.withAlphaComponent(0.11)
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        table.tableHeaderView = UIView()
        self.view.addSubview(table)
    }
    
    func addAccountView() {
        let height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        
        accountView = UIView(frame: CGRect(x: 0, y: height, width: self.view.frame.width, height: 66))
        let imageView = UIImageView(image: user.profileImage)
        imageView.frame = CGRect(x: 0, y: 3, width: 60, height: 60)
        imageView.frame.origin.x = 10
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        
        let nameLabel = UILabel(frame: CGRect(x: 16, y: accountView.frame.height/2 - 40, width: self.view.frame.width-32, height: 40))
        nameLabel.text = "logged in with"
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        nameLabel.textColor = .gray
        nameLabel.textAlignment = .center
        nameLabel.sizeToFit()
        nameLabel.frame.origin.y = accountView.frame.height/2 - nameLabel.frame.height
        
        let email = UILabel(frame: CGRect(x: 16, y: accountView.frame.height/2, width: self.view.frame.width-32, height: 40))
        email.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        email.textColor = .black
        email.textAlignment = .center
        email.text = user.email
        email.sizeToFit()
        email.frame.origin.y = accountView.frame.height/2
        
        if user.loggedInWithFacebook {
            accountView.addSubview(imageView)
            nameLabel.frame.origin.x = imageView.endX() + 10
            nameLabel.textAlignment = .left
            nameLabel.text = user.firstName + " " + user.lastName
            nameLabel.textColor = .black
            nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            nameLabel.sizeToFit()
            email.frame.origin.x = imageView.endX() + 10
            email.textAlignment = .left
            email.font = UIFont.systemFont(ofSize: 14, weight: .light)
        }
        
        
        accountView.addBottomBorderWithColor(color: UIColor.black.withAlphaComponent(0.05), width: 0.5)
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [Colors.navbarBG.cgColor, UIColor.white.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: accountView.frame.width, height: accountView.frame.height)
        gradientLayer.locations = [0, 1.0]
        
        accountView.layer.insertSublayer(gradientLayer, at: UInt32(0))
        
        accountView.addSubview(nameLabel)
        accountView.addSubview(email)
        self.view.addSubview(accountView)
    }
    
    func addAmountOfShiftsElement() {
        amountShiftsView = UIView()
        
        amountShiftsLbl = UILabel()
        amountShiftsLbl.font = UIFont.systemFont(ofSize: 60, weight: .light)
        amountShiftsLbl.text = Periods.totalShifts().description
        amountShiftsLbl.textAlignment = .center
        amountShiftsLbl.textColor = .black
        
        var textSize = amountShiftsLbl.text?.sizeOfString(usingFont: amountShiftsLbl.font)
        amountShiftsLbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: textSize!.height)
        
        shiftsLbl = UILabel()
        shiftsLbl.font = UIFont.systemFont(ofSize: 12, weight: .light)
        shiftsLbl.text = "completed shifts"
        shiftsLbl.textAlignment = .center
        shiftsLbl.textColor = .gray
        shiftsLbl.sizeToFit()
        
        textSize = shiftsLbl.text?.sizeOfString(usingFont: shiftsLbl.font)
        shiftsLbl.frame = CGRect(x: 0, y: amountShiftsLbl.endY(), width: self.view.frame.width, height: textSize!.height)
        amountShiftsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: amountShiftsLbl.frame.height + shiftsLbl.frame.height)
        amountShiftsLbl.textAlignment = .center
        
        amountShiftsView.addSubview(shiftsLbl)
        amountShiftsView.addSubview(amountShiftsLbl)
        self.view.addSubview(amountShiftsView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        Periods.makePeriod(yearIndex: indexForChosenPeriod[0], monthIndex: indexForChosenPeriod[1], successHandler: {})
        if textField.tag == 1 {
            if textField.text == "" {
                textField.text = "0"
            }
            
            user.settings.wage = Float(textField.text!)!
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["wage": user.settings.wage]])
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width:
            tableView.bounds.size.width, height: 30))
        headerLabel.font = UIFont.boldSystemFont(ofSize: 11)
        headerLabel.text = ["App settings", "Account"][section]
        headerLabel.center.y = 15
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = .white
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsCell
        let titles = [
            ["Tax rate", "Hourly rate", "Currency", "Advanced tools"],
            (user.loggedInWithFacebook) ? ["Log out"] : ["Change email", "Change password", "Log out"]
        ]
        let imageNames = [
            ["government_filled", "wagerate_filled", "currency_filled", "tool_filled"],
            (user.loggedInWithFacebook) ? ["logout_filled"] : ["email_filled", "password_filled", "logout_filled"]
        ]
        let image = UIImage(named: imageNames[indexPath.section][indexPath.row])
        
        cell.textLabel?.text = titles[indexPath.section][indexPath.row]
        cell.img.image = image
        cell.field.layer.opacity = 0
        cell.field.frame.origin.x = self.view.frame.width - 15 - cell.field.frame.width
        
        if (indexPath.section == 0 && indexPath.row < 3) {
            cell.field.layer.opacity = 1
            cell.selectionStyle = .none

            if indexPath.row == 0 {
                taxrateField = cell.field
                taxrateField.tintColor = .clear
                taxrateField.inputView = taxPicker
                taxrateField.textColor = .black
                taxrateField.font = UIFont.systemFont(ofSize: 14, weight: .light)
                taxrateField.delegate = self
                taxrateField.text = String(user.settings.tax.round(decimals: 1)) + " %"
            } else if indexPath.row == 1 {
                wageRateField = cell.field
                wageRateField.clearsOnBeginEditing = true
                wageRateField.keyboardType = .decimalPad
                wageRateField.textColor = .black
                wageRateField.font = UIFont.systemFont(ofSize: 14, weight: .light)
                wageRateField.delegate = self
                wageRateField.tag = 1
                wageRateField.text = String(user.settings.wage)
            } else {
                currencyField = cell.field
                currencyField.tintColor = UIColor.clear
                currencyField.inputView = currencyPicker
                currencyField.textColor = .black
                currencyField.font = UIFont.systemFont(ofSize: 14, weight: .light)
                currencyField.delegate = self
                currencyField.text = user.settings.currency
            }
        }
        
        return cell
    }
    
    func configurePickers() {
        taxPicker.tag = 1
        taxPicker.delegate = self
        taxPicker.dataSource = self
        
        currencyPicker.tag = 2
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }
    func configureView() {
        self.title = "Account"
        let textAttributes = [NSAttributedString.Key.foregroundColor: Colors.navbarFG]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barTintColor = Colors.navbarBG
        self.hideNavBarSeparator()
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
            user.settings.tax = Float(taxString)!
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["tax": user.settings.tax]])
        } else {
            currencyField.text = currencies[row]
            user.settings.currency = currencyField.text!
            CloudStorage.updateSetting(toUser: user.ID, obj: ["settings": ["currency": user.settings.currency]])
        }
    }
    func createTaxString(part1: String, part2: String) -> String {
        var returnString = ""
        returnString = part1 + "." + part2 + " %"
        return returnString
    }
    
    func populateWithSettings() {
        // TAX
        let taxRate = String(user.settings.tax.round(decimals: 1))
        taxrateField.text = taxRate + " %"
        taxPicker.selectRow(Int(Float(taxRate)!), inComponent: 0, animated: true)
        taxPicker.selectRow(Int(String(Array(taxRate)[(taxRate.count)-1]))!, inComponent: 2, animated: true)
        
        // WAGE
        wageRateField.text = String(Int(user.settings.wage))
        
        // CURRENCY
        currencyField.text = user.settings.currency
        currencyPicker.selectRow(currencies.index(of: currencyField.text!)!, inComponent: 0, animated: true)
    }
}
