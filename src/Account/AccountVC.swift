//
//  AccountVC.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class AccountVC: UIViewController {
    
    var accountInfoView: UIView!
    var userEmailLabel: UILabel!
    var changePasswordBtn: UIButton!
    var changeEmailBtn: UIButton!
    var logoutButton: UIButton!
    
    var updateForm: UpdateForm!
    
    var isUpdatingPassword = true
    var loadingIndicator: UIActivityIndicatorView!
    var updateMessageLbl: UILabel!
    
    override func viewDidLoad() {
        self.title = "Account"
        self.navigationController?.navigationBar.tintColor = .black
        
        addAccountInfo()
        addLogoutBtn()
        addChangeEmailBtn()
        addChangePasswordBtn()
        addUpdatingForm()
        createLoadingIndicator()
        createUpdateMessageLabel()
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
            UserDefaults().set(updateForm.field2.text, forKey: "password")
            showSuccessMessage(msg: "Updated password!")
        } else {
            userEmailLabel.text = updateForm.field1.text
            UserDefaults().set(userEmailLabel.text, forKey: "email")
            showSuccessMessage(msg: "Updated email!")
        }
        
        loadingIndicator.stopAnimating()
        updateForm.formButton.setTitle("Update", for: .normal)
        hideForm()
    }
    
    @objc func onChangePasswordPress() {
        isUpdatingPassword = true
        updateForm.field1.placeholder = "New password"
        updateForm.field2.placeholder = "Confirm password"
        showUpdateForm()
    }
    @objc func onChangeEmailPress() {
        isUpdatingPassword = false
        updateForm.field1.placeholder = "New email"
        updateForm.field2.placeholder = "Confirm email"
        showUpdateForm()
    }
    @objc func onLogout() {
        user = nil
        UserSettings.forgetLoginInfo()
        performSegue(withIdentifier: "backtologin", sender: self)
    }
    @objc func showUpdateForm() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x -= self.view.frame.width
            
            self.changePasswordBtn.center.x -= self.view.frame.width
            self.changeEmailBtn.center.x -= self.view.frame.width
            self.logoutButton.center.x -= self.view.frame.width
            self.accountInfoView.center.x -= self.view.frame.width
        })
    }
    @objc func hideForm() {
        updateForm.clear()
        updateForm.hideErrorMessage()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.updateForm.center.x += self.view.frame.width
            
            self.changePasswordBtn.center.x += self.view.frame.width
            self.changeEmailBtn.center.x += self.view.frame.width
            self.logoutButton.center.x += self.view.frame.width
            self.accountInfoView.center.x += self.view.frame.width
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
        view.addSubview(updateForm)
    }
    func addChangeEmailBtn() {
        changeEmailBtn = UIButton()
        changeEmailBtn.setTitle("Change email", for: .normal)
        changeEmailBtn.setTitleColor(.black, for: .normal)
        changeEmailBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        changeEmailBtn.sizeToFit()
        changeEmailBtn.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.6)
        changeEmailBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        changeEmailBtn.addTarget(self, action: #selector(onChangeEmailPress), for: .touchUpInside)
        self.view.addSubview(changeEmailBtn)
    }
    func addChangePasswordBtn() {
        changePasswordBtn = UIButton()
        changePasswordBtn.setTitle("Change password", for: .normal)
        changePasswordBtn.setTitleColor(.black, for: .normal)
        changePasswordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        changePasswordBtn.sizeToFit()
        changePasswordBtn.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.6 + 20)
        changePasswordBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        changePasswordBtn.addTarget(self, action: #selector(onChangePasswordPress), for: .touchUpInside)
        
        self.view.addSubview(changePasswordBtn)
    }
    func addLogoutBtn() {
        logoutButton = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 40))
        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.backgroundColor = navColor
        logoutButton.tintColor = .white
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        logoutButton.addTarget(self, action: #selector(onLogout), for: .touchUpInside)
        logoutButton.layer.cornerRadius = 20
        logoutButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.75)
        
        self.view.addSubview(logoutButton)
    }
    func addAccountInfo() {
        accountInfoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        let lbl = UILabel()
        lbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lbl.text = "Logged in with"
        lbl.textAlignment = .center
        lbl.center = self.view.center
        
        userEmailLabel = UILabel()
        userEmailLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        userEmailLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        userEmailLabel.text = user.email
        userEmailLabel.textAlignment = .center
        userEmailLabel.center = self.view.center
        userEmailLabel.center.y += 20
        
        accountInfoView.addSubview(lbl)
        accountInfoView.addSubview(userEmailLabel)
        self.view.addSubview(accountInfoView)
    }
}
