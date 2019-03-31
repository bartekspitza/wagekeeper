//
//  CloudStorage.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-05.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CloudStorage {
    
    static func getAllShifts(fromUser: String, completionHandler: @escaping ([Shift]) -> ()) {
        let db = Firestore.firestore()
        
        let shiftsCollection = db.collection("users").document(fromUser).collection("shifts")
        print(shiftsCollection.path)
        shiftsCollection.getDocuments(completion: { (query, er) in
            if er == nil {
                var arr = [Shift]()
                for doc in ((query?.documents)!) {
                    let shiftID = doc.documentID
                    let shiftData = doc.data()
                    
                    let s = Shift(
                        title:          shiftData["title"]!             as! String,
                        date:           (shiftData["date"]!             as! String).toDateTime(),
                        startingTime:   (shiftData["startingTime"]!     as! String).toDateTime(),
                        endingTime:     (shiftData["endingTime"]!       as! String).toDateTime(),
                        breakTime:      shiftData["breakTime"]!         as! Int,
                        note:           shiftData["note"]!              as! String,
                        newPeriod:      shiftData["beginsNewPeriod"]!   as! Bool,
                        ID:             ""
                    )
                    s.ID = shiftID
                    arr.append(s)
                }
                print("Fetched data from cloud (" + arr.count.description + " items)")
                completionHandler(arr)
            } else {
                print("Couldn't fetch data from the cloud\nError message: " + er!.localizedDescription)
            }
        })
    }
    
    static func getSettings(toUser: String, completionHandler: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userDoc = db.document("users/" + toUser)
        
        userDoc.getDocument { (query, er) in
            if er != nil {
                print(er!.localizedDescription)
            } else {
                if let data = query!.data() {
                    user.settings = Settings.createFromDocumentSnapshot(data: data)
                }
                
            }
            completionHandler()
        }
    }
    
    static func updateSetting(toUser: String, obj: [String: Any]) {
        let db = Firestore.firestore()
        let userDoc = db.document("users/" + toUser)
        
        userDoc.setData(obj, merge: true) { (er) in
            if er == nil {
                print("Updated setting.")
            } else {
                print(er!.localizedDescription)
            }
        }
    }
    
    static func updateOvertime(toUser: String, obj: [String: Any]) {
        let db = Firestore.firestore()
        let userDoc = db.document("users/" + toUser)
        
        userDoc.setData(obj, mergeFields: ["settings.overtime"]) { (er) in
            if er == nil {
                print("Updated setting.")
            } else {
                print(er!.localizedDescription)
            }
        }
    }
    
    static func addShift(toUser: String, shift: Shift, completionHandler: @escaping () -> () ) {
        let db = Firestore.firestore()
        let shiftsCollection = db.collection("users/" + toUser + "/shifts/")
        
        let document = shiftsCollection.addDocument(data: [
            "title": shift.title,
            "date": shift.date.description,
            "startingTime": shift.startingTime.description,
            "endingTime": shift.endingTime.description,
            "breakTime": shift.breakTime,
            "note": shift.note,
            "beginsNewPeriod": shift.beginsNewPeriod
        ]) { (er) in
            if er == nil {
                print("Added shift to cloud")
                completionHandler()
                print(shiftsCollection.path)
            } else {
                print("Couldn't add shift to the cloud\nError message: " + er!.localizedDescription)
            }
        }
        shift.ID = document.documentID
    }
    
    static func deleteShift(fromUser: String, shift: Shift) {
        let db = Firestore.firestore()
        let shiftsCollection = db.collection("users/" + fromUser + "/shifts/")
        
        shiftsCollection.document(shift.ID).delete { (er) in
            if er == nil {
                print("Deleted shift from cloud: " + shift.ID)
            } else {
                print("Couldnt delete shift (" + shift.ID + ") from cloud\n Error message: " + er!.localizedDescription)
            }
        }
    }
    
    static func updateShift(from: Shift, with: Shift, user: String, completionHandler: @escaping () -> ()) {
        let db = Firestore.firestore()
        let shiftsCollection = db.collection("users/" + user + "/shifts/")
        
        shiftsCollection.document(from.ID).setData([
            "title": with.title,
            "date": with.date.description,
            "startingTime": with.startingTime.description,
            "endingTime": with.endingTime.description,
            "breakTime": with.breakTime,
            "note": with.note,
            "beginsNewPeriod": with.beginsNewPeriod
        ]) { (er) in
            if er == nil {
                print("Updated shift in cloud: " + from.ID)
                completionHandler()
            } else {
                print("Couldnt update shift (" + from.ID + ") from cloud\n Error message: " + er!.localizedDescription)
            }
            
        }
    }
    
}
