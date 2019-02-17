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
    
    static func sendResetEmail(to: String, successHandler: @escaping () -> (), failureHandler: @escaping (String) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: to) { (er) in
            if er == nil {
                successHandler()
            } else {
                let code = (er! as NSError).code
                failureHandler(errorCodeToString(code: code))
            }
        }
    }
    
    static func updatePassword(password: String, successHandler: @escaping () -> (), failureHandler: @escaping (String) -> ()) {
        let user = Auth.auth().currentUser
        
        if user != nil {
            user?.updatePassword(to: password, completion: { (er) in
                if er == nil {
                    successHandler()
                } else {
                    let code = (er! as NSError).code
                    failureHandler(errorCodeToString(code: code))
                }
            })
        } else {
            failureHandler("Something went wrong. We are sorry")
        }
    }
    
    static func updateEmail(newEmail: String, successHandler: @escaping () -> (), failureHandler: @escaping (String) -> ()) {
        let user = Auth.auth().currentUser
        
        if user != nil {
            user?.updateEmail(to: newEmail, completion: { (er) in
                if er == nil {
                    successHandler()
                } else {
                    print(er!.localizedDescription)
                    let code = (er! as NSError).code
                    failureHandler(errorCodeToString(code: code))
                }
            })
        } else {
            failureHandler("We're sorry. Something went wrong")
        }
    }
    
    static func login(email: String, password: String, successHandler: @escaping (AuthDataResult) -> (), failureHandler: @escaping (_ message: String) -> ()) {
        print("Attempting to log in")
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, er) in
            if er == nil {
                print("User logged in!")
                successHandler(result!)
                
            } else {
                let e = er! as NSError
                failureHandler(errorCodeToString(code: e.code))
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
                failureHandler(errorCodeToString(code: e.code))
            }
        }
    }
    
    static private func errorCodeToString(code: Int) -> String {
        var msg = "We're sorry. Something went wrong"
        
        if code == 17011 {
            msg = "No account found with that email adress"
        } else if code == 17009 {
            msg = "Wrong password"
        } else if code == 17008 {
            msg = "Email is badly formatted"
        } else if code == 17026 {
            msg = "Password must be atleast 6 characters long"
        }
        
        return msg
    }
}
