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

class AuthVC: UIViewController, UITextFieldDelegate {
    

    var loginForm: LoginForm!
    var createAccountForm: CreateAccountForm!
    let loadingIndicator = UIActivityIndicatorView()
    
    let toolbar = UIToolbar()
    
    var email = ""
    var password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        configureToolbar()
        addLoginForm()
        addCreateAccountForm()
        addLoadingIndicator()
        addLogoImage()
    }
    
    // Authentication
    func performLogin(result: AuthDataResult) {
        loadingIndicator.stopAnimating()
        user = User(ID: result.user.uid, email: result.user.email!)
        UserSettings.saveLoginInfo(email: email, password: password)
        performSegue(withIdentifier: "tabbar", sender: self)
    }
    func onLoginFailure(message: String) {
        loadingIndicator.stopAnimating()
        loginForm.stopAnimating()
        loginForm.showErrorMessage(message: message)
    }
    func onCreateAccountFailure(message: String) {
        loadingIndicator.stopAnimating()
        loginForm.stopAnimating()
        createAccountForm.showErrorMessage(message: message)
    }
    @objc func createAccount() {
        email = createAccountForm.emailField.text!
        password = createAccountForm.passwordField.text!
        
        createAccountForm.hideErrorMessage()
        
        let pass2 = createAccountForm.password2Field.text
        
        if password == "" || email == "" || pass2 == "" {
            createAccountForm.showErrorMessage(message: "All fields must be entered")
        } else if password != pass2 {
            createAccountForm.showErrorMessage(message: "Passwords must match")
        } else {
            loadingIndicator.startAnimating()
            createAccountForm.startAnimating()
            CloudAuth.createUserAccount(email: email, password: password, completionHandler: self.performLogin, failureHandler: self.onCreateAccountFailure)
        }
    }
    @objc func login() {
        email = loginForm.emailField.text!
        password = loginForm.passwordField.text!
        loginForm.hideErrorMessage()
        
        if email == "" || password == "" {
            loginForm.showErrorMessage(message: "Both fields must be entered")
        } else {
            loadingIndicator.startAnimating()
            loginForm.startAnimating()
            CloudAuth.login(email: email, password: password, successHandler: self.performLogin, failureHandler: self.onLoginFailure)
        }
    }
    @objc func resetPassword() {
        if loginForm.emailField.text == "" {
            loginForm.showErrorMessage(message: "Field must be entered")
        } else {
            loginForm.hideErrorMessage()
            loginForm.startAnimating()
            loadingIndicator.startAnimating()
            CloudAuth.sendResetEmail(to: loginForm.emailField.text!, successHandler: {
                self.loginForm.stopAnimating()
                self.loadingIndicator.stopAnimating()
                self.loginForm.showSuccessMessage(msg: "Reset email sent")
                self.hideForgotPasswordView()
            }) { (msg) in
                self.loginForm.showErrorMessage(message: msg)
                self.loginForm.stopAnimating()
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    // Layout methods
    func configureToolbar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        doneButton.tintColor = .black
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
    }
    func addLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        loadingIndicator.center = CGPoint(x: self.view.center.x, y: self.view.frame.height/2 + loginForm.mainBtn.center.y)
        self.view.addSubview(loadingIndicator)
    }
    func addCreateAccountForm() {
        let frame = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2)
        createAccountForm = CreateAccountForm(frame: frame, mainBtnTitle: "Create account")
        createAccountForm.create()
        createAccountForm.center.x += createAccountForm.frame.width
        createAccountForm.accessoryBtn.addTarget(self, action: #selector(presentLoginForm), for: .touchUpInside)
        createAccountForm.emailField.delegate = self
        createAccountForm.emailField.inputAccessoryView = toolbar
        createAccountForm.passwordField.delegate = self
        createAccountForm.passwordField.inputAccessoryView = toolbar
        createAccountForm.password2Field.delegate = self
        createAccountForm.password2Field.inputAccessoryView = toolbar
        createAccountForm.mainBtn.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        createAccountForm.configureErrorLabel()
        
        self.view.addSubview(createAccountForm)
    }
    func addLoginForm() {
        loginForm = LoginForm(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2), mainBtnTitle: "Log in")
        self.view.addSubview(loginForm)
        
        loginForm.create()
        loginForm.accessoryBtn.addTarget(self, action: #selector(presentCreateForm), for: .touchUpInside)
        loginForm.mainBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginForm.emailField.delegate = self
        loginForm.emailField.inputAccessoryView = toolbar
        loginForm.passwordField.delegate = self
        loginForm.passwordField.inputAccessoryView = toolbar
        loginForm.forgotPassBtn.addTarget(self, action: #selector(presentForgotPasswordView), for: .touchUpInside)
        loginForm.configureErrorLabel()
    }
    func addLogoImage() {
        let image = UIImage(named: "icon.png")
        
        let imageView = UIImageView(image: image)
        imageView.setImageColor(color: navColor)
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.width/2)
        imageView.center = CGPoint(x: self.view.center.x + 10, y: self.view.frame.height*0.25)
        
        self.view.addSubview(imageView)
    }
    
    // Methods for switching views between logging, creating and forgetting password
    @objc func presentForgotPasswordView() {
        loginForm.hideErrorMessage()
        UIView.animate(withDuration: 0.3) {
            self.loginForm.passwordField.layer.opacity = 0
            self.loginForm.forgotPassBtn.layer.opacity = 0
        }
        
        UIView.transition(with: self.loginForm.mainBtn, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.loginForm.mainBtn.setTitle("Send reset email", for: .normal)
            self.loginForm.accessoryBtn.setTitle("Cancel", for: .normal)
        }) { (true) in
            self.loginForm.accessoryBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.accessoryBtn.addTarget(self, action: #selector(self.hideForgotPasswordView), for: .touchUpInside)
            self.loginForm.mainBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.mainBtn.addTarget(self, action: #selector(self.resetPassword), for: .touchUpInside)
        }

    }
    @objc func hideForgotPasswordView() {
        loginForm.hideErrorMessage()
        UIView.animate(withDuration: 0.3) {
            self.loginForm.passwordField.layer.opacity = 1
            self.loginForm.forgotPassBtn.layer.opacity = 1
        }
        
        UIView.transition(with: self.loginForm.mainBtn, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.loginForm.mainBtn.setTitle("Log in", for: .normal)
            self.loginForm.accessoryBtn.setTitle("Create account", for: .normal)
        }) { (true) in
            self.loginForm.accessoryBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.accessoryBtn.addTarget(self, action: #selector(self.presentCreateForm), for: .touchUpInside)
            self.loginForm.mainBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.mainBtn.addTarget(self, action: #selector(self.login), for: .touchUpInside)
        }
        
    }
    @objc func presentLoginForm() {
        loadingIndicator.center.y = self.view.frame.height/2 + loginForm.mainBtn.center.y
        createAccountForm.hideErrorMessage()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.loginForm.center.x += self.loginForm.frame.width
            self.createAccountForm.center.x += self.createAccountForm.frame.width
        }) { (true) in
            self.createAccountForm.clear()
        }
    }
    @objc func presentCreateForm() {
        loadingIndicator.center.y = self.view.frame.height/2 + createAccountForm.mainBtn.center.y
        loginForm.hideErrorMessage()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.loginForm.center.x -= self.loginForm.frame.width
            self.createAccountForm.center.x -= self.createAccountForm.frame.width
        }) { (true) in
            self.loginForm.clear()
        }
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @objc func keyboardWillShow(notification: Notification) {
        if self.view.frame.origin.y == 0 {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= 150
            })
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame.origin.y = 0
        })
    }
}
