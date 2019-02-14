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
    static private func loginErrorCodeToString(code: Int) -> String {
        var msg = "Something went wrong. We're sorry."

        if code == 17011 {
            msg = "No account found with that email adress"
        } else if code == 17009 {
            msg = "Wrong password"
        } else if code == 17008 {
            msg = "Email is badly formatted"
        }
        
        return msg
    }
    
    static private func createAccountErrorCodeToString(code: Int) -> String {
        var msg = "Something went wrong. We're sorry."
        
        if code == 17026 {
            msg = "Password must be atleast 6 characters long"
        } else if code == 17008 {
            msg = "Email is badly formatted"
        }
        
        return msg
    }
    
    static func login(email: String, password: String, successHandler: @escaping (AuthDataResult) -> (), failureHandler: @escaping (_ message: String) -> ()) {
        print("Attempting to log in")
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, er) in
            if er == nil {
                print("User logged in!")
                successHandler(result!)
                
            } else {
                let e = er! as NSError
                failureHandler(loginErrorCodeToString(code: e.code))
            }
            
        }
    }
    
    static func createUserAccount(email: String, password: String, completionHandler: @escaping (AuthDataResult) -> (), failureHandler: @escaping (_ message: String) -> ()) {
        print("Attempting to create user")
        Auth.auth().createUser(withEmail: email, password: password) { (result, er) in
            if er == nil {
                print("User created!")
                completionHandler(result!)
                
            } else {
                let e = er! as NSError
                print(e.code)
                failureHandler(createAccountErrorCodeToString(code: e.code))
            }
        }
    }
}
