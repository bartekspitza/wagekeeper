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
                    endingTime: shiftST,
                    startingTime: shiftET,
                    lunchTime: shiftBreak,
                    note: shiftNote,
                    newPeriod: shiftIsNewPeriod
                )
                s.ID = shiftID
                arr.append(s)
                
            }
            completionHandler(arr)
        })
    }
    
    static func addShift(toUser: String, shift: ShiftModel) {
        let db = Firestore.firestore()
        let shiftsCollection = db.collection("users/" + toUser + "/shifts/")
        
        
        shiftsCollection.addDocument(data: [
            "date": shift.date.description,
            "startingtime": shift.startingTime.description,
            "endingtime": shift.endingTime.description,
            "break": shift.lunchTime,
            "note": shift.note,
            "beginsNewPeriod": shift.beginsNewPeriod
        ])
    }
    
    static func deleteShift(fromUser: String, shift: ShiftModel) {
        let db = Firestore.firestore()
        let shiftsCollection = db.collection("users/" + fromUser + "/shifts/")
        
        shiftsCollection.document(shift.ID).delete()
    }
    
}
