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
    var userArea: String?
    var userAge: String?
    var userSex: String?
    var userGoodInt: Int?
    var userBadInt: Int?

    var petId: String?
    var petName: String?
    var breederId: String?
    
    var startDate: String?
    var endDate: String?
    var actualStartDate: String?
    var actualEndDate: String?

    var suggestFlag: Bool?
    var acceptFlag: Bool?
    var runningFlag: Bool?
    var completeFlag: Bool?
    var stopFlag: Bool?
    var abortFlag: Bool?
    
    var userComment: String?
    var breederComment: String?
    
    var createAt:NSDate?
    var updateAt:NSDate?
    
    init(snapshot: DataSnapshot, myId: String) {
        print("DEBUG_PRINT: LeaveData.init start")
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.userId = valueDictionary["userId"] as? String
        self.userName = valueDictionary["userName"] as? String
        self.userArea = valueDictionary["userArea"] as? String
        self.userAge = valueDictionary["userAge"] as? String
        self.userSex = valueDictionary["userSex"] as? String
        self.userGoodInt = valueDictionary["userGoodInt"] as? Int
        self.userBadInt = valueDictionary["userBadInt"] as? Int

        
        self.petId = valueDictionary["petId"] as? String
        self.petName = valueDictionary["petName"] as? String
        self.breederId = valueDictionary["breederId"] as? String
        
        self.startDate = valueDictionary["startDate"] as? String
        self.endDate = valueDictionary["endDate"] as? String
        self.actualStartDate = valueDictionary["actualStartDate"] as? String
        self.actualEndDate = valueDictionary["actualEndDate"] as? String
        
        self.suggestFlag = valueDictionary["suggestFlag"] as? Bool
        self.acceptFlag = valueDictionary["acceptFlag"] as? Bool
        self.runningFlag = valueDictionary["runningFlag"] as? Bool
        self.completeFlag = valueDictionary["completeFlag"] as? Bool
        self.stopFlag = valueDictionary["stopFlag"] as? Bool
        self.abortFlag = valueDictionary["abortFlag"] as? Bool
                
        self.userComment = valueDictionary["userComment"] as? String
        self.breederComment = valueDictionary["breederComment"] as? String

        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        
        print("DEBUG_PRINT: LeaveData.init end")
    }
}
