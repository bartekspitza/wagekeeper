//
//  CreateAccountView.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-06.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class CreateAccountView: LoginView{
    
    var createBtn: UIButton!
    
    override func viewDidLoad() {
        self.addEmailFieldToView()
        self.addPasswordFieldToView()
        self.addCreateAccountButton()
    }
    
    
    
    @objc override func buttonAction() {
        let email = emailField.text
        let password = passwordField.text
        
        if email == "" || password == "" {
            print("both fields must be entered")
        } else {
            CloudAuth.createUserAccount(email: email!, password: password!, completionHandler: onCreateAccountSucess)
        }
    }
    
    func onCreateAccountSucess(result: AuthDataResult) {
        user = User(ID: result.user.uid, email: result.user.email!)
        performSegue(withIdentifier: "gotoTabbar", sender: self)

    }
}
