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

    var senderId: String?
    var senderDisplayName: String?
    var text: String?
    var image: UIImage?
    var imageString: String?
    var timestamp: NSDate?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: MessageData.init start")
        print(snapshot)

        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.senderId = valueDictionary["senderId"] as? String
        self.senderDisplayName = valueDictionary["senderDisplayName"] as? String
        if let text = valueDictionary["text"] as? String {
            self.text = text
        } else if let imageString = valueDictionary["imageString"] as? String  {
            self.image = UIImage(data: NSData(base64Encoded: imageString, options: .ignoreUnknownCharacters)! as Data)
        }
        
        let timestamp = valueDictionary["timestamp"] as? String
        print(timestamp)
        self.timestamp = NSDate(timeIntervalSinceReferenceDate: TimeInterval(timestamp!)!)

        print("DEBUG_PRINT: MessageData.init end")
    }
}
