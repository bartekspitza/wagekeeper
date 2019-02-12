//
//  LoginUIView.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class LoginUIView: UIView {
    
    var emailField: UITextField!
    var passwordField: UITextField!
    var loginBtn: UIButton!
    var createAccountBtn: UIButton!
    var forgotPassBtn: UIButton!
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }
    
    func addForgotPasswordButton() {
        forgotPassBtn = UIButton()
        forgotPassBtn.setTitle("Forgot password", for: .normal)
        forgotPassBtn.setTitleColor(.black, for: .normal)
        forgotPassBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        forgotPassBtn.sizeToFit()
        
        forgotPassBtn.center = CGPoint(x: self.view.center.x, y: loginBtn.center.y + loginBtn.frame.height/2 + forgotPassBtn.frame.height/2 + 5)
        
        self.view.addSubview(forgotPassBtn)
    }
    
    func addCreateAccountButton() {
        createAccountBtn = UIButton()
        createAccountBtn.setTitle("Create account", for: .normal)
        createAccountBtn.setTitleColor(.black, for: .normal)
        createAccountBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        createAccountBtn.sizeToFit()
        createAccountBtn.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        createAccountBtn.center = CGPoint(x: self.view.center.x, y: loginView.frame.height * 0.9)
        
        self.view.addSubview(createAccountBtn)
    }
    
    func addLoginButtonToView() {
        loginBtn = UIButton(frame: CGRect(x: 50, y: 50, width: self.view.frame.width*0.75, height: 40))
        loginBtn.setTitle("Log in", for: .normal)
        loginBtn.backgroundColor = navColor
        loginBtn.tintColor = .white
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        loginBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        loginBtn.layer.cornerRadius = 10
        
        loginBtn.center = CGPoint(x: self.view.center.x, y: emailField.center.y + 120)
        
        self.view.addSubview(loginBtn)
    }
    
    func addEmailFieldToView() {
        emailField = UITextField()
        emailField.delegate = self
        emailField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.75, height: 40)
        emailField.placeholder = "Email"
        emailField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        emailField.borderStyle = .roundedRect
        emailField.autocapitalizationType = .none
        
        emailField.center = CGPoint(x: self.view.center.x, y: emailField.frame.height/2)
        
        self.view.addSubview(emailField)
    }
    
    func addPasswordFieldToView() {
        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.75, height: 40)
        passwordField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.autocapitalizationType = .none
        
        passwordField.center = self.view.center
        passwordField.center.y = emailField.center.y + emailField.frame.height + 10
        
        self.view.addSubview(passwordField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
