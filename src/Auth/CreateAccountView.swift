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
    
    var btn: UIButton!
    
    override func viewDidLoad() {
        self.addEmailFieldToView()
        self.addPasswordFieldToView()
        self.addCreateAccountButton()
    }
    
    func addCreateAccountButton() {
        btn = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        btn.setTitle("Log in", for: .normal)
        btn.backgroundColor = UIColor.blue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(btn)
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
        user = User(ID: result.user.uid)
        performSegue(withIdentifier: "gotoTabbar", sender: self)

    }
}
