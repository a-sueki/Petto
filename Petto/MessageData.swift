//
//  MessageData.swift
//  Petto
//
//  Created by admin on 2017/07/09.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
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
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.senderId = valueDictionary["senderId"] as? String
        self.senderDisplayName = valueDictionary["senderDisplayName"] as? String
        self.text = valueDictionary["text"] as? String
        imageString = valueDictionary["imageString"] as? String
        self.image = UIImage(data: NSData(base64Encoded: imageString!, options: .ignoreUnknownCharacters)! as Data)
        let timestamp = valueDictionary["timestamp"] as? String
        self.timestamp = NSDate(timeIntervalSinceReferenceDate: TimeInterval(timestamp!)!)

    }
}
