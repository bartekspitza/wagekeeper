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
    // what is needed:
    //
    
    
    override func viewDidLoad() {
        self.title = "Account"
        self.navigationController?.navigationBar.tintColor = .black
        
        
        label()
        btn()
    }
    
    
    func btn() {
        let loginBtn = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 50))
        loginBtn.setTitle("Log out", for: .normal)
        loginBtn.backgroundColor = navColor
        loginBtn.tintColor = .white
        loginBtn.addTarget(self, action: #selector(btnaction), for: .touchUpInside)
        loginBtn.layer.cornerRadius = 25
        loginBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 200)
        
        self.view.addSubview(loginBtn)
    }
    
    @objc func btnaction() {
        performSegue(withIdentifier: "backtologin", sender: self)
    }
    
    func label() {
        let lbl = UILabel()
        lbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lbl.text = "Logged in with: " + user.email
        lbl.center = self.view.center
        
        self.view.addSubview(lbl)
    }
    
}
