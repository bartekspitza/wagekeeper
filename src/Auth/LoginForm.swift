//
//  LoginForm.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit
import Firebase
import EMSpinnerButton
import PasswordTextField

class LoginForm: UIView {
    
    var emailField: UITextField!
    var passwordField: PasswordTextField!
    var mainBtn: EMSpinnerButton!
    var accessoryBtn: UIButton!
    var forgotPassBtn: UIButton!
    var errorLabel: UILabel!
    
    var errorLabelIsConfigured = false
    var mainBtnTitle: String!
    var FBButton: EMSpinnerButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func startMainBtnAnimation() {
        self.mainBtn.animate(animation: .collapse)
    }
    
    func stopMainBtnAnimation() {
        self.mainBtn.animate(animation: .expand)
    }
    
    func startFBButtonAnimation() {
        self.FBButton.animate(animation: .collapse)
    }
    
    func stopFBButtonAnimation() {
        self.FBButton.animate(animation: .expand)
    }
    
    func showSuccessMessage(msg: String) {
        errorLabel.textColor = Colors.successGreen
        errorLabel.text = msg
        errorLabel.layer.opacity = 1
        
        UIView.animate(withDuration: 2, delay: 1, options: [], animations: {
            self.errorLabel.layer.opacity = 0
        }, completion: {(true) in
                self.errorLabel.textColor = .red
            self.errorLabel.text = ""
        })
    }
    
    func showErrorMessage(message: String) {
        if !errorLabelIsConfigured {
            self.configureErrorLabel()
            errorLabelIsConfigured = true
        }
        self.errorLabel.layer.opacity = 1
        self.errorLabel.text = message
        
    }
    
    func hideErrorMessage() {
        self.errorLabel.layer.opacity = 0
    }
    
    func configureErrorLabel() {
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 20))
        errorLabel.text = "Wrong password"
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        errorLabel.center = CGPoint(x: self.center.x, y: passwordField.center.y + passwordField.frame.height/2 + 15)
        errorLabel.layer.opacity = 0
        
        self.addSubview(errorLabel)
    }
    
    func clear() {
        emailField.text = ""
        passwordField.text = ""
    }
    
    func create() {
        addEmailFieldToView()
        addPasswordFieldToView(y: emailField.center.y + emailField.frame.height + 10)
        addMainButton(title: "Log in", y: emailField.center.y + 120)
        addForgotPasswordButton()
        addAccessoryButton(title: "Create account")
        addFBButton()
    }
    func addFBButton() {
        FBButton = EMSpinnerButton(title: "Sign in with Facebook")
        FBButton.backgroundColor = Colors.fb
        FBButton.frame = CGRect(x: 0, y: 0, width: self.frame.width*0.75, height: 40)
        FBButton.center = CGPoint(x: self.center.x, y: forgotPassBtn.frame.origin.y + forgotPassBtn.frame.height + 30 + FBButton.frame.height/2)
        FBButton.setTitle("Sign in with Facebook", for: .normal)
        FBButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        FBButton.cornerRadius = 10
        FBButton.setTitleColor(.lightGray, for: .highlighted)
        self.addSubview(FBButton)
    }
    
    func addEmailFieldToView() {
        emailField = UITextField()
        emailField.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.75, height: 40)
        emailField.placeholder = "Email"
        emailField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        emailField.autocapitalizationType = .none
        emailField.center = CGPoint(x: self.center.x, y: emailField.frame.height/2)
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .no
        emailField.addBottomBorder(color: .lightGray, width: 0.5)
        
        self.addSubview(emailField)
    }
    
    
    func addPasswordFieldToView(y: CGFloat) {
        passwordField = PasswordTextField()
        passwordField.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.75, height: 40)
        passwordField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.autocorrectionType = .no
        passwordField.center = self.center
        passwordField.center.y = y
        passwordField.addBottomBorder(color: .lightGray, width: 0.5)
        
        self.addSubview(passwordField)
    }
    func addMainButton(title: String, y: CGFloat) {
        mainBtn = EMSpinnerButton(title: title)
        mainBtn.frame = CGRect(x: 50, y: 50, width: self.frame.width*0.75, height: 40)
        //mainBtn.setTitle(title, for: .normal)
        mainBtn.backgroundColor = Colors.test1
        mainBtn.tintColor = .white
        mainBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        mainBtn.cornerRadius = 10
        mainBtn.setTitleColor(.lightGray, for: .highlighted)
        mainBtn.center = CGPoint(x: self.center.x, y: y)
        
        self.addSubview(mainBtn)
    }
    func addForgotPasswordButton() {
        forgotPassBtn = UIButton()
        forgotPassBtn.setTitle("Forgot your password?", for: .normal)
        forgotPassBtn.setTitleColor(.black, for: .normal)
        forgotPassBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        forgotPassBtn.sizeToFit()
        forgotPassBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        forgotPassBtn.center = CGPoint(x: self.center.x, y: mainBtn.center.y + mainBtn.frame.height/2 + forgotPassBtn.frame.height/2 + 5)

        self.addSubview(forgotPassBtn)
    }
    func addAccessoryButton(title: String) {
        accessoryBtn = UIButton()
        accessoryBtn.setTitle(title, for: .normal)
        accessoryBtn.setTitleColor(.black, for: .normal)
        accessoryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        accessoryBtn.sizeToFit()
        accessoryBtn.center = CGPoint(x: self.center.x, y: self.frame.height * 0.9)
        accessoryBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        self.addSubview(accessoryBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
