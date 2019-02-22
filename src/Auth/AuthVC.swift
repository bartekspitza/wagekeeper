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
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin

class AuthVC: UIViewController, UITextFieldDelegate {
    
    var loginForm: LoginForm!
    var createAccountForm: CreateAccountForm!
    
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
        addLogoImage()
    }
    
    // Authentication
    @objc func facebooklogin() {
        loginForm.startAnimating(button: loginForm.FBButton)
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            
            switch loginResult {
            case .failed( _):
                self.onFacebookLoginFailure()
            case .cancelled:
                self.loginForm.stopAnimating(button: self.loginForm.FBButton, title: "Sign in with Facebook")
            case .success:
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                    if error == nil {
                        
                        user = MyUser.createFromFirebaseUser(user: result!.user)
                        
                        CloudAuth.fetchFBProfile(successHandler: {
                            self.performSegue(withIdentifier: "tabbar", sender: self)
                        }, failureHandler: {
                            self.onFacebookLoginFailure()
                        })
                        
                        
                    } else {
                        print(error!.localizedDescription)
                        self.onFacebookLoginFailure()
                    }
                    
                }
                break
            }
        }
    }

    func onFacebookLoginFailure() {
        self.loginForm.stopAnimating(button: self.loginForm.FBButton, title: "Sign in with Facebook")
        self.loginForm.showErrorMessage(message: "Something went wrong. We're sorry.")
    }
    
    func performLogin(result: AuthDataResult) {
        user = MyUser.createFromFirebaseUser(user: result.user)
        performSegue(withIdentifier: "tabbar", sender: self)
    }
    func onLoginFailure(message: String) {
        
        loginForm.stopAnimating(button: loginForm.mainBtn, title: loginForm.mainBtnTitle)
        loginForm.showErrorMessage(message: message)
    }
    func onCreateAccountFailure(message: String) {
        createAccountForm.stopAnimating(button: createAccountForm.mainBtn, title: createAccountForm.mainBtnTitle)
        createAccountForm.showErrorMessage(message: message)
    }
    @objc func createAccount() {
        createAccountForm.hideErrorMessage()
        
        email = createAccountForm.emailField.text!
        password = createAccountForm.passwordField.text!
        let pass2 = createAccountForm.password2Field.text
        
        if password == "" || email == "" || pass2 == "" {
            createAccountForm.showErrorMessage(message: "All fields must be entered")
        } else if password != pass2 {
            createAccountForm.showErrorMessage(message: "Passwords must match")
        } else {
            createAccountForm.startAnimating(button: createAccountForm.mainBtn)
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
            loginForm.startAnimating(button: loginForm.mainBtn)
            CloudAuth.login(email: email, password: password, successHandler: self.performLogin, failureHandler: self.onLoginFailure)
        }
    }
    @objc func resetPassword() {
        if loginForm.emailField.text == "" {
            loginForm.showErrorMessage(message: "Field must be entered")
        } else {
            loginForm.hideErrorMessage()
            loginForm.startAnimating(button: loginForm.mainBtn)
            CloudAuth.sendResetEmail(to: loginForm.emailField.text!, successHandler: {
                self.loginForm.stopAnimating(button: self.loginForm.mainBtn, title: self.loginForm.mainBtnTitle)
                self.hideForgotPasswordView()
                self.loginForm.showSuccessMessage(msg: "Reset email sent")
                
                
            }) { (msg) in
                self.loginForm.stopAnimating(button: self.loginForm.mainBtn, title: "Send reset email")
                self.loginForm.showErrorMessage(message: msg)
                
            }
        }
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
        createAccountForm.hideErrorMessage()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.loginForm.center.x += self.loginForm.frame.width
            self.createAccountForm.center.x += self.createAccountForm.frame.width
        }) { (true) in
            self.createAccountForm.clear()
        }
    }
    @objc func presentCreateForm() {
        loginForm.hideErrorMessage()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.loginForm.center.x -= self.loginForm.frame.width
            self.createAccountForm.center.x -= self.createAccountForm.frame.width
        }) { (true) in
            self.loginForm.clear()
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
    
    func addCreateAccountForm() {
        let frame = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2)
        createAccountForm = CreateAccountForm(frame: frame)
        createAccountForm.mainBtnTitle = "Create account"
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
        loginForm = LoginForm(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2))
        self.view.addSubview(loginForm)
        loginForm.mainBtnTitle = "Log in"
        loginForm.create()
        loginForm.accessoryBtn.addTarget(self, action: #selector(presentCreateForm), for: .touchUpInside)
        loginForm.mainBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginForm.emailField.delegate = self
        loginForm.emailField.inputAccessoryView = toolbar
        loginForm.passwordField.delegate = self
        loginForm.passwordField.inputAccessoryView = toolbar
        loginForm.forgotPassBtn.addTarget(self, action: #selector(presentForgotPasswordView), for: .touchUpInside)
        loginForm.FBButton.addTarget(self, action: #selector(facebooklogin), for: .touchUpInside)
        loginForm.configureErrorLabel()
    }
    func addLogoImage() {
        let image = UIImage(named: "icon.png")
        
        let imageView = UIImageView(image: image)
        imageView.setImageColor(color: Colors.test1)
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.width/2)
        imageView.center = CGPoint(x: self.view.center.x + 10, y: self.view.frame.height*0.25)
        
        self.view.addSubview(imageView)
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
