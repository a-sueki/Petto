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
    var userArea: String?
    var userAge: String?
    var userGoodInt: Int?
    var userBadInt: Int?
    
    var petId: String?
    var petName: String?
    var petImage: UIImage?
    var petImageString: String?
    var breederId: String?
    
    var lastMessage:String?
//    var userOpenedFlg :Bool?
//    var petOpenedFlg :Bool?
    var createAt:NSDate?
    var updateAt:NSDate?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: RoomData.init start")
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.id = myId
        self.userId = valueDictionary["userId"] as? String
        self.userName = valueDictionary["userName"] as? String
        userImageString = valueDictionary["userImageString"] as? String
        self.userImage = UIImage(data: NSData(base64Encoded: userImageString!, options: .ignoreUnknownCharacters)! as Data)
        self.userArea = valueDictionary["userArea"] as? String
        self.userAge = valueDictionary["userAge"] as? String
        self.userGoodInt = valueDictionary["userGoodInt"] as? Int
        self.userBadInt = valueDictionary["userBadInt"] as? Int
        
        
        self.petId = valueDictionary["petId"] as? String
        self.petName = valueDictionary["petName"] as? String
        petImageString = valueDictionary["petImageString"] as? String
        self.petImage = UIImage(data: NSData(base64Encoded: petImageString!, options: .ignoreUnknownCharacters)! as Data)
        self.breederId = valueDictionary["breederId"] as? String
        self.lastMessage = valueDictionary["lastMessage"] as? String
//        self.userOpenedFlg = valueDictionary["userOpenedFlg"] as? Bool
//        self.petOpenedFlg = valueDictionary["petOpenedFlg"] as? Bool
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        
        print("DEBUG_PRINT: RoomData.init end")
    }
}
