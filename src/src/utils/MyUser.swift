//
//  FBUser.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-18.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseAuth

class MyUser {
    var ID: String
    var email: String
    var firstName: String
    var lastName: String
    var loggedInWithFacebook: Bool
    var profileImage: UIImage?
    var settings: Settings!
    
    init(ID: String, email: String, firstName: String, lastName: String, loggedInWithFacebook: Bool, settings: Settings) {
        self.ID = ID
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.loggedInWithFacebook = loggedInWithFacebook
        self.settings = settings
    }
    
    static func createFromFirebaseUser(user: User) -> MyUser {
        let email = user.email == nil ? "" : user.email!
        
        return MyUser(ID: user.uid, email: email, firstName: "", lastName: "", loggedInWithFacebook: false, settings: Settings(overtime: Overtime()))
    }
    
    func setImage(path: String) {
        let url = URL(string: path)
        let data = NSData(contentsOf: url!)
        self.profileImage = UIImage(data: data! as Data)
    }
}
