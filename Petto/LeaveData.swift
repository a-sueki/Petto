//
//  LeaveData.swift
//  Petto
//
//  Created by admin on 2017/09/03.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class LeaveData: NSObject {
    
    var id: String?
    
    var userId: String?
    var userName: String?
    var userImage: UIImage?
    var userImageString: String?
    var petId: String?
    var petName: String?
    var petImage: UIImage?
    var petImageString: String?
    var breederId: String?
    
    var startDate: String?
    var endDate: String?

    var suggestFlag: Bool?
    var acceptFlag: Bool?
    var completeFlag: Bool?
    var abortFlag: Bool?
    
    var commemorativePhote: UIImage?
    var commemorativePhoteString: String?
    var userComment: String?
    var breederComment: String?
    
    var createAt:NSDate?
    var updateAt:NSDate?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: LeaveData.init start")
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.userId = valueDictionary["userId"] as? String
        self.userName = valueDictionary["userName"] as? String
        userImageString = valueDictionary["userImageString"] as? String
        self.userImage = UIImage(data: NSData(base64Encoded: userImageString!, options: .ignoreUnknownCharacters)! as Data)
        self.petId = valueDictionary["petId"] as? String
        self.petName = valueDictionary["petName"] as? String
        petImageString = valueDictionary["petImageString"] as? String
        self.petImage = UIImage(data: NSData(base64Encoded: petImageString!, options: .ignoreUnknownCharacters)! as Data)
        self.breederId = valueDictionary["breederId"] as? String
        
        self.startDate = valueDictionary["startDate"] as? String
        self.endDate = valueDictionary["endDate"] as? String
        
        self.suggestFlag = valueDictionary["suggestFlag"] as? Bool
        self.acceptFlag = valueDictionary["acceptFlag"] as? Bool
        self.completeFlag = valueDictionary["completeFlag"] as? Bool
        self.abortFlag = valueDictionary["abortFlag"] as? Bool
        
        
        commemorativePhoteString = valueDictionary["commemorativePhoteString"] as? String
        if commemorativePhoteString != nil {
            self.commemorativePhote = UIImage(data: NSData(base64Encoded: commemorativePhoteString!, options: .ignoreUnknownCharacters)! as Data)
        }
        self.userComment = valueDictionary["userComment"] as? String
        self.breederComment = valueDictionary["breederComment"] as? String

        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        
        print("DEBUG_PRINT: LeaveData.init end")
    }
}
