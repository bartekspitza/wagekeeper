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
    
    func addLogoImage() {
        let image = UIImage(named: "testimage.png")
        
        let imageView = UIImageView(image: image)
        imageView.setImageColor(color: navColor)
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.width/2)
        imageView.center = CGPoint(x: self.view.center.x + 10, y: self.view.frame.height*0.25)
        
        
        self.view.addSubview(imageView)
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
    
   
    
    
    func onCreateAccountFailure(message: String) {
        loadingIndicator.stopAnimating()
        createAccountForm.showErrorMessage(message: message)
    }
    
    func onLoginFailure(message: String) {
        loadingIndicator.stopAnimating()
        loginForm.showErrorMessage(message: message)
    }
    
    func onLoginSucess(result: AuthDataResult) {
        loadingIndicator.stopAnimating()
        user = User(ID: result.user.uid, email: result.user.email!)
        UserSettings.saveLoginInfo(email: email, password: password)
        performSegue(withIdentifier: "tabbar", sender: self)
    }
    
    @objc func createAccountPressed() {
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
            CloudAuth.createUserAccount(email: email, password: password, completionHandler: self.onLoginSucess, failureHandler: self.onCreateAccountFailure)
        }
    }
    
    @objc func loginPressed() {
        email = loginForm.emailField.text!
        password = loginForm.passwordField.text!
        loginForm.hideErrorMessage()
        
        if email == "" || password == "" {
            loginForm.showErrorMessage(message: "Both fields must be entered")
        } else {
            loadingIndicator.startAnimating()
            CloudAuth.login(email: email, password: password, successHandler: self.onLoginSucess, failureHandler: self.onLoginFailure)
        }
    }
    
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
        loadingIndicator.center = CGPoint(x: loginForm.mainBtn.center.x + loginForm.mainBtn.frame.width/2 - loadingIndicator.frame.width - 20, y: self.view.frame.height/2 + loginForm.mainBtn.center.y)
        self.view.addSubview(loadingIndicator)
    }
    func addCreateAccountForm() {
        createAccountForm = CreateAccountForm(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2))
        createAccountForm.create()
        createAccountForm.center.x += createAccountForm.frame.width
        createAccountForm.accessoryBtn.addTarget(self, action: #selector(presentLoginForm), for: .touchUpInside)
        createAccountForm.emailField.delegate = self
        createAccountForm.emailField.inputAccessoryView = toolbar
        createAccountForm.passwordField.delegate = self
        createAccountForm.passwordField.inputAccessoryView = toolbar
        createAccountForm.password2Field.delegate = self
        createAccountForm.password2Field.inputAccessoryView = toolbar
        createAccountForm.mainBtn.addTarget(self, action: #selector(createAccountPressed), for: .touchUpInside)
        createAccountForm.configureErrorLabel()
        
        self.view.addSubview(createAccountForm)
    }
    func addLoginForm() {
        loginForm = LoginForm(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2))
        self.view.addSubview(loginForm)
        
        loginForm.create()
        loginForm.accessoryBtn.addTarget(self, action: #selector(presentCreateForm), for: .touchUpInside)
        loginForm.mainBtn.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        loginForm.emailField.delegate = self
        loginForm.emailField.inputAccessoryView = toolbar
        loginForm.passwordField.delegate = self
        loginForm.passwordField.inputAccessoryView = toolbar
        loginForm.configureErrorLabel()
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
}
