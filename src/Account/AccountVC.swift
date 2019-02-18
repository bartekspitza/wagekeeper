//
//  AccountVC.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FirebaseAuth

class AccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var accountInfoView: UIView!
    var updateForm: UpdateForm!
    
    var isUpdatingPassword = true
    var loadingIndicator: UIActivityIndicatorView!
    var updateMessageLbl: UILabel!
    var table: UITableView!
    
    override func viewDidLoad() {
        self.title = "Account"
        self.navigationController?.navigationBar.tintColor = .black
        
        addAmountOfShiftsElement()
        addUpdatingForm()
        createLoadingIndicator()
        createUpdateMessageLabel()
        createTable()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if updateForm.center.x == self.view.center.x {
            accountInfoView.layer.opacity = 0
            table.layer.opacity = 0
        }
    }
    
    func createTable() {
        table = UITableView(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 200))
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.separatorColor = UIColor.black.withAlphaComponent(0.11)
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        table.isScrollEnabled = false
        self.view.addSubview(table)
    }
    @objc func updatePressed() {
        if updateForm.field1.text == "" || updateForm.field2.text == "" {
            updateForm.showErrorMessage(message: "Both fields must be entered")
        } else if updateForm.field1.text != updateForm.field2.text {
            updateForm.showErrorMessage(message: "Fields must match")
        } else {
            loadingIndicator.startAnimating()
            updateForm.formButton.setTitle("", for: .normal)
            if isUpdatingPassword {
                CloudAuth.updatePassword(password: updateForm.field1.text!, successHandler: self.onFormOperationSuccess, failureHandler: onFormOperationFailure)
            } else {
                CloudAuth.updateEmail(newEmail: updateForm.field1.text!, successHandler: self.onFormOperationSuccess, failureHandler: onFormOperationFailure)
            }
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
    
    func logout() {
        user = nil
        performSegue(withIdentifier: "backtologin", sender: self)
        CloudAuth.signOut()
    }
    @objc func showUpdateForm() {
        
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x -= self.view.frame.width
            
            self.table.center.x -= self.view.frame.width
        }) { (true) in
            self.table.deselectAllRows()
        }
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    @objc func hideForm() {
        updateForm.clear()
        updateForm.hideErrorMessage()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x += self.view.frame.width
            
            self.table.center.x += self.view.frame.width
        })
    }
    
    // Shows message when operation from form is successful
    func showSuccessMessage(msg: String) {
        updateMessageLbl.text = msg
        updateMessageLbl.layer.opacity = 1
        
        UIView.animate(withDuration: 3) {
            self.updateMessageLbl.layer.opacity = 0
        }
    }
    
    func createUpdateMessageLabel() {
        updateMessageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        updateMessageLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        updateMessageLbl.text = "Logged in with"
        updateMessageLbl.textAlignment = .center
        updateMessageLbl.center = self.view.center
        updateMessageLbl.center.y = self.view.frame.height/4
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
        updateForm.addFormButton(title: "Update")
        updateForm.addBackButton()
        updateForm.center.x += self.view.frame.width
        updateForm.backButton.addTarget(self, action: #selector(hideForm), for: .touchUpInside)
        updateForm.formButton.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
        let toolbar = UIToolbar()
        let buttons = addButtons(bar: toolbar, withUpAndDown: true, color: .black)
        updateForm.field1.inputAccessoryView = toolbar
        updateForm.field2.inputAccessoryView = toolbar
        buttons[0].action = #selector(donePressed)
        view.addSubview(updateForm)
    }

    func addAmountOfShiftsElement() {
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        accountInfoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2))
        
        
        let shiftsAmountLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        shiftsAmountLbl.font = UIFont.systemFont(ofSize: 60, weight: .light)
        shiftsAmountLbl.text = Periods.totalShifts().description
        shiftsAmountLbl.textAlignment = .center
        shiftsAmountLbl.textColor = .black
        shiftsAmountLbl.sizeToFit()
        shiftsAmountLbl.center = CGPoint(x: self.view.center.x, y: self.view.frame.height/4)
        
        let shiftsLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        shiftsLbl.font = UIFont.systemFont(ofSize: 12, weight: .light)
        shiftsLbl.text = "completed shifts"
        shiftsLbl.textColor = .gray
        shiftsLbl.sizeToFit()
        shiftsLbl.center.y = shiftsAmountLbl.frame.origin.y + shiftsAmountLbl.font.ascender - shiftsLbl.frame.height/2 + 5
        shiftsLbl.frame.origin.x = shiftsAmountLbl.frame.origin.x + shiftsAmountLbl.frame.width + 5

        accountInfoView.center.y = self.view.frame.height/4 + navigationBarHeight
        accountInfoView.addSubview(shiftsLbl)
        accountInfoView.addSubview(shiftsAmountLbl)
        self.view.addSubview(accountInfoView)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if user.loggedInWithFacebook {
            logout()
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
                logout()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user.loggedInWithFacebook {
            return 1
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        var titles = [String]()
        var imageNames = [String]()
        
        if user.loggedInWithFacebook {
            titles = ["Log out"]
            imageNames = ["account"]
        } else {
            titles = ["Change email", "Change password", "Log out"]
            imageNames = ["email_icon", "key_icon", "account"]
        }
        
        cell?.textLabel?.text = titles[indexPath.row]
        
        let image = UIImage(named: imageNames[indexPath.row])
        let imageView = UIImageView(image: image)
        imageView.setImageColor(color: .black)
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        imageView.center = CGPoint(x: 25, y: (cell?.frame.height)!/2)
        cell?.contentView.addSubview(imageView)
        cell?.indentationLevel = 5
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if user.loggedInWithFacebook {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            
            
            let imageView = UIImageView(image: user.profileImage)
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            imageView.frame.origin.x = 10
            imageView.center.y = 25
            imageView.layer.cornerRadius = 20
            imageView.layer.masksToBounds = true
            
            let descriptionLabel = UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.width-32, height: 40))
            descriptionLabel.text = user.firstName + " " + user.lastName
            descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
            descriptionLabel.textAlignment = .center
            descriptionLabel.textColor = .gray
            
            let email = UILabel(frame: CGRect(x: 16, y: 15, width: self.view.frame.width-32, height: 40))
            email.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            email.textAlignment = .center
            email.textColor = .black
            
            email.text = user.email
            
            let separator = UIView(frame: CGRect(x: 0, y: 49, width: self.view.frame.width, height: 0.5))
            separator.backgroundColor = UIColor.black.withAlphaComponent(0.11)
            
            view.addSubview(descriptionLabel)
            view.addSubview(email)
            view.addSubview(imageView)
            view.addSubview(separator)
            
            return view
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            
            
            let descriptionLabel = UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.width-32, height: 40))
            descriptionLabel.text = "logged in with"
            descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
            descriptionLabel.textAlignment = .center
            descriptionLabel.textColor = .gray
            
            let email = UILabel(frame: CGRect(x: 16, y: 15, width: self.view.frame.width-32, height: 40))
            email.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            email.textAlignment = .center
            email.textColor = .black
            
            email.text = user.email
            
            
            let separator = UIView(frame: CGRect(x: 0, y: 49, width: self.view.frame.width, height: 0.5))
            separator.backgroundColor = UIColor.black.withAlphaComponent(0.11)
            
            view.addSubview(descriptionLabel)
            view.addSubview(separator)
            view.addSubview(email)
            
            return view
        }
        
    }
}
