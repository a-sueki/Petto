//
//  MemberData.swift
//  Petto
//
//  Created by admin on 2017/08/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//


import Firebase
import FirebaseDatabase

class MemberData: NSObject {
    
    var roomId: String?
    var userId: String?
    var petId: String?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: MemberData.init start")
        print(snapshot)
        
        self.roomId = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.userId = valueDictionary["userId"] as? String
        self.petId = valueDictionary["petId"] as? String
        
        print("DEBUG_PRINT: MemberData.init end")
    }
}
