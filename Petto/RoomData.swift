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
    var userImage: UIImage?
    var userImageString: String?
    var petId: String?
    var petName: String?
    var petImage: UIImage?
    var petImageString: String?
    var lastMessage:String?
    var createAt:NSDate?
    var updateAt:NSDate?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: RoomData.init start")
        print(snapshot)
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        // 一覧表示用
        self.userId = valueDictionary["userId"] as? String
        self.userName = valueDictionary["userName"] as? String
        userImageString = valueDictionary["userImageString"] as? String
        self.userImage = UIImage(data: NSData(base64Encoded: userImageString!, options: .ignoreUnknownCharacters)! as Data)
        self.petId = valueDictionary["petId"] as? String
        self.petName = valueDictionary["petName"] as? String
        petImageString = valueDictionary["petImageString"] as? String
        self.petImage = UIImage(data: NSData(base64Encoded: petImageString!, options: .ignoreUnknownCharacters)! as Data)
        self.lastMessage = valueDictionary["lastMessage"] as? String
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        
        print("DEBUG_PRINT: RoomData.init end")
    }
}