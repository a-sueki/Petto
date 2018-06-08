//
//  MessageData.swift
//  Petto
//
//  Created by admin on 2017/07/09.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class MessageData: NSObject {
    
    var id: String?

    // チャット用
    var senderId: String?
    var senderDisplayName: String?
    var text: String?
    var timestamp: NSDate?
    
    init(snapshot: DataSnapshot, myId: String) {
        print("DEBUG_PRINT: MessageData.init start")
        print(snapshot)

        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
 
        // チャット用
        self.senderId = valueDictionary["senderId"] as? String
        self.senderDisplayName = valueDictionary["senderDisplayName"] as? String
        if let text = valueDictionary["text"] as? String {
            self.text = text
        }
        
        let timestamp = valueDictionary["timestamp"] as? String
        self.timestamp = NSDate(timeIntervalSinceReferenceDate: TimeInterval(timestamp!)!)

        print("DEBUG_PRINT: MessageData.init end")
    }
}
