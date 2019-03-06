//
//  CreateAccountForm.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit
import PasswordTextField

class CreateAccountForm: LoginForm {
    
    var password2Field: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func clear() {
        emailField.text = ""
        password2Field.text = ""
        passwordField.text = ""
    }
    
    override func create() {
        addEmailFieldToView()
        addPasswordFieldToView(y: emailField.center.y + 50)
        addPassword2FieldToView()
        
        addMainButton(title: "Create account", y: password2Field.center.y + 70)
        addAccessoryButton(title: "Log in")
        addLoadingIndicator()
    }
    
    override func configureErrorLabel() {
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 20))
        errorLabel.text = "Wrong password"
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        errorLabel.center = CGPoint(x: self.center.x, y: password2Field.center.y + password2Field.frame.height/2 + 15)
        errorLabel.layer.opacity = 0
        
        self.addSubview(errorLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPassword2FieldToView() {
        password2Field = PasswordTextField()
        password2Field.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.75, height: 40)
        password2Field.placeholder = "Confirm password"
        password2Field.font = UIFont.systemFont(ofSize: 14, weight: .light)
        password2Field.autocapitalizationType = .none
        password2Field.isSecureTextEntry = true
        password2Field.center = CGPoint(x: self.center.x, y: passwordField.center.y + 50)
        password2Field.addBottomBorder(color: .lightGray, width: 0.5)
        password2Field.attributedPlaceholder = NSAttributedString(string: "Confirm password",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        self.addSubview(password2Field)
    }
    
}
