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

class LoginForm: UIView {
    
    var emailField: UITextField!
    var passwordField: UITextField!
    var mainBtn: UIButton!
    var accessoryBtn: UIButton!
    var forgotPassBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
    }

    func addEmailFieldToView() {
        emailField = UITextField()
        emailField.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.75, height: 40)
        emailField.placeholder = "Email"
        emailField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        emailField.borderStyle = .roundedRect
        emailField.autocapitalizationType = .none
        emailField.center = CGPoint(x: self.center.x, y: emailField.frame.height/2)
        
        self.addSubview(emailField)
    }
    
    
    func addPasswordFieldToView(y: CGFloat) {
        passwordField = UITextField()
        passwordField.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.75, height: 40)
        passwordField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        
        passwordField.center = self.center
        passwordField.center.y = y
        
        self.addSubview(passwordField)
    }
    func addMainButton(title: String, y: CGFloat) {
        mainBtn = UIButton(frame: CGRect(x: 50, y: 50, width: self.frame.width*0.75, height: 40))
        mainBtn.setTitle(title, for: .normal)
        mainBtn.backgroundColor = navColor
        mainBtn.tintColor = .white
        mainBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        mainBtn.layer.cornerRadius = 10
        
        mainBtn.center = CGPoint(x: self.center.x, y: y)
        
        self.addSubview(mainBtn)
    }
    func addForgotPasswordButton() {
        forgotPassBtn = UIButton()
        forgotPassBtn.setTitle("Forgot password", for: .normal)
        forgotPassBtn.setTitleColor(.black, for: .normal)
        forgotPassBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        forgotPassBtn.sizeToFit()

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

        self.addSubview(accessoryBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
