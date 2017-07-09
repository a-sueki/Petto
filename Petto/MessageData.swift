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
    // 送信者
    var senderUid: String?
    var senderName: String?
    var receiverUid: String?
    var receiverName: String?
    var image: UIImage?
    var imageString: String?
    var text: String?
    var timestamp: NSDate?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        // 個人情報
        imageString = valueDictionary["image"] as? String
        self.image = UIImage(data: NSData(base64Encoded: imageString!, options: .ignoreUnknownCharacters)! as Data)
        self.senderUid = valueDictionary["senderUid"] as? String
        self.senderName = valueDictionary["senderName"] as? String
        self.receiverUid = valueDictionary["receiverUid"] as? String
        self.receiverName = valueDictionary["receiverName"] as? String
        self.text = valueDictionary["text"] as? String
        let timestamp = valueDictionary["timestamp"] as? String
        self.timestamp = NSDate(timeIntervalSinceReferenceDate: TimeInterval(timestamp!)!)
    }
}
