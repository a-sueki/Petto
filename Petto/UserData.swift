//
//  File.swift
//  Petto
//
//  Created by admin on 2017/07/08.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserData: NSObject {
    
    var id: String?
    // 評価
    var goods: [String] = []
    var isGooded: Bool = false
    var bads: [String] = []
    var isBaded: Bool = false
    // 個人情報
    var image: UIImage?
    var imageString: String?
    var firstname: String?
    var lastname: String?
    var birthday: String?
    var zipCode: String?
    var address: String?
    var area: String?
    var tel: String?

    //追加情報
    var hasAnotherPet: Bool?        // 他にペットを飼っている
    var isExperienced: Bool?        // ペット飼育経験あり
    var historyId: String?          // Petto利用履歴
//    var environment: [String] = []  // 飼育環境
//    var equipment: [String] = []    // 飼育道具
    
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        // 評価
        if let goods = valueDictionary["goods"] as? [String] {
            self.goods = goods
        }
        for raterId in self.goods {
            if raterId == myId {
                self.isGooded = true
                break
            }
        }
        if let bads = valueDictionary["bads"] as? [String] {
            self.bads = bads
        }
        for raterId in self.bads {
            if raterId == myId {
                self.isBaded = true
                break
            }
        }
        // 個人情報
        imageString = valueDictionary["image"] as? String
        self.image = UIImage(data: NSData(base64Encoded: imageString!, options: .ignoreUnknownCharacters)! as Data)
        self.firstname = valueDictionary["firstname"] as? String
        self.lastname = valueDictionary["lastname"] as? String
        self.birthday = valueDictionary["birthday"] as? String
        self.zipCode = valueDictionary["zipCode"] as? String
        self.address = valueDictionary["address"] as? String
        self.area = valueDictionary["area"] as? String
        self.tel = valueDictionary["tel"] as? String
        self.hasAnotherPet = valueDictionary["hasAnotherPet"] as? Bool
        self.isExperienced = valueDictionary["isExperienced"] as? Bool
        self.historyId = valueDictionary["historyId"] as? String

    }
}
