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
    // ログイン情報
    var mail: String?
    var nickname: String?
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
    var hasAnotherPet: Bool?        // 他にペットを飼っている
    var isExperienced: Bool?        // ペット飼育経験あり
    //あずかり情報
    var environments = [String:Bool]()
    var tools = [String:Bool]()
    var ngs = [String:Bool]()
    var historyId: String?          // Petto利用履歴
    // マイペット情報
    var myPetsId: [String] = []
    // システム項目
    var createAt: NSDate?
    var createBy: String?
    var updateAt: NSDate?
    var updateBy: String?

    
    
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
        // ログイン情報
        self.mail = valueDictionary["mail"] as? String
        self.nickname = valueDictionary["nickname"] as? String

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
        if let environments = valueDictionary["environments"] as? [String:Bool] {
            self.environments = environments
        }
        if let tools = valueDictionary["tools"] as? [String:Bool] {
            self.tools = tools
        }
        if let ngs = valueDictionary["ngs"] as? [String:Bool] {
            self.ngs = ngs
        }
        self.historyId = valueDictionary["historyId"] as? String

        // マイペット情報
        if let myPetsId = valueDictionary["myPetsId"] as? [String] {
            self.myPetsId = myPetsId
        }
        // システム項目
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        self.createBy = valueDictionary["createBy"] as? String
        let updateAt = valueDictionary["updateAt"] as? String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        self.updateBy = valueDictionary["updateBy"] as? String

    }
}
