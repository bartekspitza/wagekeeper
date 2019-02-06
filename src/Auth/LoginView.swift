//
//  View.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-06.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginView: UIViewController, UITextFieldDelegate {
    
    var emailField: UITextField!
    var passwordField: UITextField!
    var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEmailFieldToView()
        addPasswordFieldToView()
        addLoginButtonToView()
        
    }
    
    func addLoginButtonToView() {
        loginBtn = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        loginBtn.setTitle("Log in", for: .normal)
        loginBtn.backgroundColor = UIColor.blue
        loginBtn.tintColor = .white
        loginBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(loginBtn)
    }
    
    @objc func buttonAction() {
        let email = emailField.text
        let password = passwordField.text
        
        if email == "" || password == "" {
            print("both fields must be entered")
        } else {
            CloudAuth.login(email: email!, password: password!, completionHandler: self.onLoginSucess)
        }
    }
    
    func onLoginSucess(result: AuthDataResult) {
        let id = result.user.uid
        user = User(ID: id)
        
        performSegue(withIdentifier: "tabbar", sender: self)
    }
        
        
    
    func addEmailFieldToView() {
        emailField = UITextField()
        emailField.delegate = self
        emailField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.75, height: 40)
        emailField.center = self.view.center
        emailField.placeholder = "enter email"
        emailField.borderStyle = UITextField.BorderStyle.line
        emailField.autocapitalizationType = .none
        self.view.addSubview(emailField)
    }
    
    func addPasswordFieldToView() {
        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.75, height: 40)
        passwordField.center = self.view.center
        passwordField.center.y = self.view.center.y + 50
        passwordField.placeholder = "enter password"
        passwordField.borderStyle = UITextField.BorderStyle.line
        passwordField.autocapitalizationType = .none
        self.view.addSubview(passwordField)
    }
    
}
