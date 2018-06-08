//
//  RoomData.swift
//  Petto
//
//  Created by admin on 2017/08/28.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class RoomData: NSObject {
    
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
    
    var lastMessage:String?
    var todoRoomIds = [String:Bool]()
    var createAt:NSDate?
    var updateAt:NSDate?
    // ブロックしたユーザーもしくはペット
    var blocked: String?

    init(snapshot: DataSnapshot, myId: String) {
        print("DEBUG_PRINT: RoomData.init start")
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.id = myId
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
        self.lastMessage = valueDictionary["lastMessage"] as? String

        if let todoRoomIds = valueDictionary["todoRoomIds"] as? [String:Bool] {
            self.todoRoomIds = todoRoomIds
        }
        
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        self.blocked = valueDictionary["blocked"] as? String

        print("DEBUG_PRINT: RoomData.init end")
    }
}
