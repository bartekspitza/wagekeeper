//
//  CloudAuth.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-06.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseAuth
import FacebookLogin
import FBSDKCoreKit

class CloudAuth {
    
    static func signOut() {
        
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
        
        if user.loggedInWithFacebook {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
    }
    
    static func userIsLoggedInWithFacebook() -> Bool {
        let currentUser = Auth.auth().currentUser
        
        if currentUser!.providerData.count > 0 {
            let loggedInWithFacebook = (currentUser!.providerData[0]).providerID == "facebook.com"
            return loggedInWithFacebook && FBSDKAccessToken.current() != nil
        }
        
        return false
    }
    
    static func fetchFBProfile(successHandler: @escaping () -> (), failureHandler: @escaping () -> () ) {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, email, picture.width(100).height(100)"])
        graphRequest?.start(completionHandler: { (connection, result, er) in
            if er == nil {
                
                // Extracts user information from FB profile
                if let fields = result as? [String: Any],
                    let firstName = fields["first_name"] as? String,
                    let lastName = fields["last_name"] as? String,
                    let email = fields["email"] as? String {
                    user.firstName = firstName
                    user.lastName = lastName
                    user.email = email
                    
                    // Tries to get profile picture URL
                    if let imageURL = ((fields["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        user.profileImage = UIImage(data: data! as Data)
                        print(url)
                    }
                    
                    user.loggedInWithFacebook = true
                    successHandler()
                } else {
                    print("Tried to retrieve first name, last name and email from FB Profile but failed")
                    failureHandler()
                }
            } else {
                print("Couldn't make graph request")
                failureHandler()
            }
        })
    }
    
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
                print(e.localizedDescription)
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
        var msg: String!
        
        switch (code) {
        case 17007:
            msg = "Account with given email adress already exists"
            break
        case 17008:
            msg = "Email is badly formatted"
            break
        case 17009:
            msg = "Wrong password"
            break
        case 17011:
            msg = "No account found with that email adress"
            break
        case 17026:
            msg = "Password must be atleast 6 characters long"
            break
        default:
            msg = "We're sorry. Something went wrong"
            break
        }
        
        return msg
    }
}
