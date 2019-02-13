//
//  AccountVC.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-12.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class AccountVC: UIViewController {
    
    override func viewDidLoad() {
        self.title = "Account"
        self.navigationController?.navigationBar.tintColor = .black
        
        
        label()
        addLogoutBtn()
    }
    
    
    func addLogoutBtn() {
        let loginBtn = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 40))
        loginBtn.setTitle("Log out", for: .normal)
        loginBtn.backgroundColor = navColor
        loginBtn.tintColor = .white
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        loginBtn.addTarget(self, action: #selector(btnaction), for: .touchUpInside)
        loginBtn.layer.cornerRadius = 20
        loginBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 200)
        
        self.view.addSubview(loginBtn)
    }
    
    @objc func btnaction() {
        user = nil
        UserSettings.forgetLoginInfo()
        performSegue(withIdentifier: "backtologin", sender: self)
    }
    
    func label() {
        let lbl = UILabel()
        lbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lbl.text = "Logged in with"
        lbl.textAlignment = .center
        lbl.center = self.view.center
        
        let lbl2 = UILabel()
        lbl2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        lbl2.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl2.text = user.email
        lbl2.textAlignment = .center
        lbl2.center = self.view.center
        lbl2.center.y += 20
        
        self.view.addSubview(lbl)
        self.view.addSubview(lbl2)
    }
    
}
