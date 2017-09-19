//
//  ContactData.swift
//  Petto
//
//  Created by admin on 2017/09/19.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class ContactData: NSObject {
    
    var id: String
    var mail: String
    var name: String
    var text: String
    var createAt: NSDate
    var createBy: String
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: ContactData.init start")
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.mail = valueDictionary["mail"] as! String
        self.name = valueDictionary["name"] as! String
        self.text = valueDictionary["text"] as! String
        let createAtString = valueDictionary["createAt"] as! String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAtString)!)
        self.createBy = valueDictionary["createBy"] as! String
        
        print("DEBUG_PRINT: ContactData.init end")
    }
}
