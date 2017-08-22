//
//  RoomData.swift
//  Petto
//
//  Created by admin on 2017/08/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class RoomData: NSObject {
    
    var id: String?
    
    var lastMessage: String?
    var createAt: NSDate?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: RoomData.init start")
        print(snapshot)
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.lastMessage = valueDictionary["lastMessage"] as? String
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        
        print("DEBUG_PRINT: RoomData.init end")
    }
}
