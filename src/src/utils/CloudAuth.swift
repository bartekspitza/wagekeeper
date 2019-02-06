//
//  CloudAuth.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-06.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseAuth

class CloudAuth {
    static func login(email: String, password: String, completionHandler: @escaping (AuthDataResult) -> ()) {
        print("Attempting to log in")
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, er) in
            if er == nil {
                print("User logged in!")
                completionHandler(result!)
                
            } else {
                print("Couldn't log in user")
                print(er!.localizedDescription)
            }
            
        }
    }
    
    static func createUserAccount(email: String, password: String, completionHandler: @escaping (AuthDataResult) -> ()) {
        print("Attempting to create user")
        Auth.auth().createUser(withEmail: email, password: password) { (result, er) in
            if er == nil {
                print("User created!")
                completionHandler(result!)
                
            } else {
                print("Couldn't create account.")
                print(er!.localizedDescription)
            }
        }
    }
}
