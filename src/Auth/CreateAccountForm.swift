//
//  CreateAccountForm.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class CreateAccountForm: LoginForm {
    
    var emailField2: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func clear() {
        emailField.text = ""
        emailField2.text = ""
        passwordField.text = ""
    }
    
    override func create() {
        addEmailFieldToView()
        addEmailField2ToView()
        addPasswordFieldToView(y: emailField2.center.y + 50)
        addMainButton(title: "Create account", y: passwordField.center.y + 70)
        addAccessoryButton(title: "Log in")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addEmailField2ToView() {
        emailField2 = UITextField()
        emailField2.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.75, height: 40)
        emailField2.placeholder = "Confirm email"
        emailField2.font = UIFont.systemFont(ofSize: 14, weight: .light)
        emailField2.borderStyle = .roundedRect
        emailField2.autocapitalizationType = .none
        emailField2.center = CGPoint(x: self.center.x, y: emailField.frame.height*1.5 + 10)
        
        self.addSubview(emailField2)
    }
    
}
