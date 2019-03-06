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

    var email = ""
    var password = ""

    var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = Colors.theme
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)

        addLoginForm()
        addCreateAccountForm()
        addLogoImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if loginViewShouldAnimate {
            loginForm.layer.opacity = 0
            logo.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            logo.center = self.view.center
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if loginViewShouldAnimate {
            UIView.animate(withDuration: 0.3) {
                self.logo.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.width/2)
                self.logo.center = CGPoint(x: self.view.center.x, y: self.view.frame.height/5)
                self.loginForm.layer.opacity = 1
            }
        }
    }
    
    // Authentication
    @objc func facebooklogin() {
        loginViewShouldAnimate = false
        loginForm.FBButton.startAnimating()
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            
            switch loginResult {
            case .failed( _):
                self.onFacebookLoginFailure()
            case .cancelled:
                self.loginForm.FBButton.stopAnimating(newTitle: nil)
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
        loginForm.FBButton.stopAnimating(newTitle: nil)
        loginForm.showErrorMessage(message: "Something went wrong. We're sorry.")
    }
    
    func performLogin(result: AuthDataResult) {
        user = MyUser.createFromFirebaseUser(user: result.user)
        performSegue(withIdentifier: "tabbar", sender: self)
    }
    func onLoginFailure(message: String) {
        
        loginForm.mainBtn.stopAnimating(newTitle: nil)
        loginForm.showErrorMessage(message: message)
    }
    func onCreateAccountFailure(message: String) {
        createAccountForm.mainBtn.stopAnimating(newTitle: nil)
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
            createAccountForm.mainBtn.startAnimating()
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
            loginForm.mainBtn.startAnimating()
            CloudAuth.login(email: email, password: password, successHandler: self.performLogin, failureHandler: self.onLoginFailure)
        }
    }
    @objc func resetPassword() {
        if loginForm.emailField.text == "" {
            loginForm.showErrorMessage(message: "Field must be entered")
        } else {
            loginForm.hideErrorMessage()
            loginForm.mainBtn.startAnimating()
            CloudAuth.sendResetEmail(to: loginForm.emailField.text!, successHandler: {
                self.loginForm.mainBtn.stopAnimating(newTitle: nil)
                self.hideForgotPasswordView()
                self.loginForm.showSuccessMessage(msg: "Reset email sent")
                
                
            }) { (msg) in
                self.loginForm.mainBtn.stopAnimating(newTitle: "Send reset email")
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
            self.loginForm.mainBtn.button.setTitle("Send reset email", for: .normal)
            self.loginForm.accessoryBtn.setTitle("Cancel", for: .normal)
        }) { (true) in
            self.loginForm.accessoryBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.accessoryBtn.addTarget(self, action: #selector(self.hideForgotPasswordView), for: .touchUpInside)
            self.loginForm.mainBtn.button.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.mainBtn.button.addTarget(self, action: #selector(self.resetPassword), for: .touchUpInside)
        }

    }
    @objc func hideForgotPasswordView() {
        loginForm.hideErrorMessage()
        UIView.animate(withDuration: 0.3) {
            self.loginForm.passwordField.layer.opacity = 1
            self.loginForm.forgotPassBtn.layer.opacity = 1
        }
        
        UIView.transition(with: self.loginForm.mainBtn, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.loginForm.mainBtn.button.setTitle("Log in", for: .normal)
            self.loginForm.accessoryBtn.setTitle("Create account", for: .normal)
        }) { (true) in
            self.loginForm.accessoryBtn.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.accessoryBtn.addTarget(self, action: #selector(self.presentCreateForm), for: .touchUpInside)
            self.loginForm.mainBtn.button.removeTarget(nil, action: nil, for: .allEvents)
            self.loginForm.mainBtn.button.addTarget(self, action: #selector(self.login), for: .touchUpInside)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Layout methods
    func addCreateAccountForm() {
        let frame = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2)
        createAccountForm = CreateAccountForm(frame: frame)
        createAccountForm.mainBtnTitle = "Create account"
        createAccountForm.create()
        createAccountForm.center.x += createAccountForm.frame.width
        createAccountForm.accessoryBtn.addTarget(self, action: #selector(presentLoginForm), for: .touchUpInside)
        createAccountForm.emailField.delegate = self
        createAccountForm.passwordField.delegate = self
        createAccountForm.password2Field.delegate = self
        createAccountForm.mainBtn.button.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        createAccountForm.configureErrorLabel()
        
        self.view.addSubview(createAccountForm)
    }
    func addLoginForm() {
        loginForm = LoginForm(frame: CGRect(x: 0, y: self.view.frame.height*0.4, width: self.view.frame.width, height: self.view.frame.height*0.6))
        self.view.addSubview(loginForm)
        loginForm.mainBtnTitle = "Log in"
        loginForm.create()
        loginForm.accessoryBtn.addTarget(self, action: #selector(presentCreateForm), for: .touchUpInside)
        loginForm.mainBtn.button.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginForm.emailField.delegate = self
        loginForm.passwordField.delegate = self
        loginForm.forgotPassBtn.addTarget(self, action: #selector(presentForgotPasswordView), for: .touchUpInside)
        loginForm.FBButton.button.addTarget(self, action: #selector(facebooklogin), for: .touchUpInside)
        loginForm.configureErrorLabel()
    }
    func addLogoImage() {
        let image = UIImage(named: "app_icon")
        
        logo = UIImageView(image: image)
        //logo.setImageColor(color: Colors.theme)
        logo.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.width/2)
        logo.center = CGPoint(x: self.view.center.x, y: self.view.frame.height*0.2)
        
        self.view.addSubview(logo)
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
