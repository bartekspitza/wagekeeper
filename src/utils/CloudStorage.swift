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
    
    static func insertShifts(items: [Shift], successHandler: @escaping () -> (), failureHandler: @escaping () -> ()) {
        let db = Firestore.firestore()
        let shiftsRef = db.collection("users/" + user.ID + "/shifts/")
        var batch = db.batch()
        
        for i in 0..<items.count {
            let newDocumentID = shiftsRef.document()
            let shift = ShiftModel.createFromCoreData(s: items[i])
            
            if i % 500 == 0 {
                // 500 items added to batch, should try and write to DB and delete 500 from the local storage
                batch.commit { (error) in
                    if error == nil {
                        print("Made a batch write of 500 items")
                    } else {
                        print("Something went wrong. Aborting the migration of local data")
                        print(error!.localizedDescription)
                        return
                    }
                }
                batch = db.batch()
            }
            
            batch.setData([
                "title": shift.title,
                "date": shift.date.description,
                "startingTime": shift.startingTime.description,
                "endingTime": shift.endingTime.description,
                "breakTime": shift.breakTime,
                "note": shift.note,
                "beginsNewPeriod": shift.beginsNewPeriod
                ], forDocument: newDocumentID)
        }
        batch.commit { (error) in
            if error == nil {
                print("Made a batch write with the rest of items")
                successHandler()
            } else {
                failureHandler()
                print(error!.localizedDescription)
            }
        }
    }
    
    static func getAllShifts(fromUser: String, completionHandler: @escaping ([ShiftModel]) -> ()) {
        let db = Firestore.firestore()
        
        let shiftsCollection = db.collection("users").document(fromUser).collection("shifts")
        print(shiftsCollection.path)
        shiftsCollection.getDocuments(completion: { (query, er) in
            if er == nil {
                var arr = [ShiftModel]()
                for doc in ((query?.documents)!) {
                    let shiftID = doc.documentID
                    let shiftData = doc.data()
                    
                    let s = ShiftModel(
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
    
    static func migrateUserDefaultsToCloud(toUser: String) {
        if UserDefaults().bool(forKey: "hasUpdatedTo2.1") == false {
            var obj = [String: Any]()
            if let tax = UserDefaults().string(forKey: "taxRate") {
                obj["tax"] = Float(tax)!
                user.settings.tax = Float(tax)!
            }
            if let wage = UserDefaults().string(forKey: "wageRate") {
                obj["wage"] = Int(wage)!
                user.settings.wage = Float(wage)!
            }
            if let currency = UserDefaults().string(forKey: "currency") {
                if currency != "" {
                    obj["currency"] = currency
                    user.settings.currency = currency
                }
            }
            if let title = UserDefaults().string(forKey: "defaultNote") {
                obj["title"] = title
                user.settings.title = title
            }
            if let breakTime = UserDefaults().string(forKey: "defaultLunch") {
                obj["break"] = Int(breakTime)!
                user.settings.breakTime = Int(breakTime)!
            }
            if let ST = UserDefaults().value(forKey: "defaultST") {
                obj["starting"] = ST as! Date
                user.settings.startingTime = ST as! Date
            }
            if let ET = UserDefaults().value(forKey: "defaultET") {
                obj["ending"] = ET as! Date
                user.settings.endingTime = ET as! Date
            }
            
            CloudStorage.updateSetting(toUser: toUser, obj: ["settings": obj])
            UserDefaults().set(true, forKey: "hasUpdatedTo2.1")
        }
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
        
//        userDoc.updateData(obj) { (er) in
//            if er == nil {
//                print("Updated setting.")
//            } else {
//                print(er!.localizedDescription)
//            }
//        }
        userDoc.setData(obj, merge: true) { (er) in
            if er == nil {
                print("Updated setting.")
            } else {
                print(er!.localizedDescription)
            }
        }
    }
    
    static func addShift(toUser: String, shift: ShiftModel, completionHandler: @escaping () -> () ) {
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
    
    static func deleteShift(fromUser: String, shift: ShiftModel) {
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
    
    static func updateShift(from: ShiftModel, with: ShiftModel, user: String, completionHandler: @escaping () -> ()) {
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
