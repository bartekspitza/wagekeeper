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
    
    
    
    static func getAllShifts(fromUser: String, completionHandler: @escaping ([ShiftModel]) -> ()) {
        let db = Firestore.firestore()
        
        let shiftsCollection = db.collection("users").document(fromUser).collection("shifts")

        shiftsCollection.getDocuments(completion: { (query, er) in
            if er == nil {
                var arr = [ShiftModel]()
                for doc in ((query?.documents)!) {
                    let shiftID = doc.documentID
                    let shiftData = doc.data()
                    
                    let shiftDate = (shiftData["date"]! as! String).toDateTime()
                    let shiftST = (shiftData["startingtime"]! as! String).toDateTime()
                    let shiftET = (shiftData["endingtime"]! as! String).toDateTime()
                    let shiftBreak = shiftData["break"]! as! String
                    let shiftNote = shiftData["note"]! as! String
                    let shiftIsNewPeriod = shiftData["beginsNewPeriod"]! as! Int16
                    
                    let s = ShiftModel(
                        date: shiftDate,
                        endingTime: shiftET,
                        startingTime: shiftST,
                        lunchTime: shiftBreak,
                        note: shiftNote,
                        newPeriod: shiftIsNewPeriod
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
    
    static func addShift(toUser: String, shift: ShiftModel, completionHandler: @escaping () -> () ) {
        let db = Firestore.firestore()
        let shiftsCollection = db.collection("users/" + toUser + "/shifts/")
        
        shiftsCollection.addDocument(data: [
            "date": shift.date.description,
            "startingtime": shift.startingTime.description,
            "endingtime": shift.endingTime.description,
            "break": shift.lunchTime,
            "note": shift.note,
            "beginsNewPeriod": shift.beginsNewPeriod
        ]) { (er) in
            if er == nil {
                print("Added shift to cloud")
                completionHandler()
            } else {
                print("Couldn't add shift to the cloud\nError message: " + er!.localizedDescription)
            }
        }
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
            "date": with.date.description,
            "startingtime": with.startingTime.description,
            "endingtime": with.endingTime.description,
            "break": with.lunchTime,
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
