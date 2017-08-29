//
//  File.swift
//  Petto
//
//  Created by admin on 2017/07/08.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

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
    var hasAnotherPet: Bool?        // 他にペットを飼っている
    var isExperienced: Bool?        // ペット飼育経験あり
    var ngs = [String:Bool]()
    
    //あずかり情報
    var expectTo: Bool?             // ペットあずかりを希望する
    var userEnvironments = [String:Bool]()
    var userTools = [String:Bool]()
    var userNgs = [String:Bool]()
    var historyId: String?      // Petto利用履歴
    // マイペット情報
    var myPets = [String:Bool]()
    // メッセージ情報
    var myMessages = [String:Bool]()
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

        // 個人情報
        imageString = valueDictionary["imageString"] as? String
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
        if let ngs = valueDictionary["ngs"] as? [String:Bool] {
            self.ngs = ngs
        }

        //あずかり情報
        self.expectTo = valueDictionary["expectTo"] as? Bool
        if let userEnvironments = valueDictionary["userEnvironments"] as? [String:Bool] {
            self.userEnvironments = userEnvironments
        }
        if let userTools = valueDictionary["userTools"] as? [String:Bool] {
            self.userTools = userTools
        }
        if let userNgs = valueDictionary["userNgs"] as? [String:Bool] {
            self.userNgs = userNgs
        }
        self.historyId = valueDictionary["historyId"] as? String

        // マイペット情報
        if let myPets = valueDictionary["myPets"] as? [String:Bool] {
            self.myPets = myPets
        }
        // メッセージ情報
        if let myMessages = valueDictionary["myMessages"] as? [String:Bool] {
            self.myMessages = myMessages
        }
        // システム項目
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        self.createBy = valueDictionary["createBy"] as? String
        if let updateAt = valueDictionary["updateAt"] as? String {
            self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt)!)
            self.updateBy = valueDictionary["updateBy"] as? String
        }

    }
}
