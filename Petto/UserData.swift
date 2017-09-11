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
    
    // 必須
    var id: String
    var image: UIImage
    var imageString: String
    var sex: String
    var firstname: String
    var lastname: String
    var birthday: String
    var area: String
    var age: String
    var hasAnotherPet: Bool        // 他にペットを飼っている
    var isExperienced: Bool        // ペット飼育経験あり
    var expectTo: Bool             // ペットあずかりを希望する
    var enterDetails: Bool // add
    var createAt: NSDate
    var createBy: String
    var updateAt: NSDate
    var updateBy: String

    // 任意
    var ngs = [String:Bool]()
    var userEnvironments = [String:Bool]()
    var userTools = [String:Bool]()
    var userNgs = [String:Bool]()
    var myPets = [String:Bool]()
    var roomIds = [String:Bool]()
    var unReadRoomIds = [String:Bool]()
    var todoRoomIds = [String:Bool]()
    var goods: [String] = []
    var isGooded: Bool = false
    var bads: [String] = []
    var isBaded: Bool = false
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: UserData.init start")
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        // 必須
        self.id = myId
        self.imageString = valueDictionary["imageString"] as! String
        self.image = UIImage(data: NSData(base64Encoded: self.imageString, options: .ignoreUnknownCharacters)! as Data)!
        self.sex = valueDictionary["sex"] as! String
        self.firstname = valueDictionary["firstname"] as! String
        self.lastname = valueDictionary["lastname"] as! String
        self.birthday = valueDictionary["birthday"] as! String
        self.area = valueDictionary["area"] as! String
        self.age = valueDictionary["age"] as! String
        self.hasAnotherPet = valueDictionary["hasAnotherPet"] as! Bool
        self.isExperienced = valueDictionary["isExperienced"] as! Bool
        self.expectTo = valueDictionary["expectTo"] as! Bool
        self.enterDetails = valueDictionary["enterDetails"] as! Bool
        let createAtString = valueDictionary["createAt"] as! String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAtString)!)
        self.createBy = valueDictionary["createBy"] as! String
        let updateAtString = valueDictionary["createAt"] as! String
        self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAtString)!)
        self.updateBy = valueDictionary["updateBy"] as! String
        
        // 任意
        if let ngs = valueDictionary["ngs"] as? [String:Bool] {
            self.ngs = ngs
        }
        if let userEnvironments = valueDictionary["userEnvironments"] as? [String:Bool] {
            self.userEnvironments = userEnvironments
        }
        if let userTools = valueDictionary["userTools"] as? [String:Bool] {
            self.userTools = userTools
        }
        if let userNgs = valueDictionary["userNgs"] as? [String:Bool] {
            self.userNgs = userNgs
        }
        if let myPets = valueDictionary["myPets"] as? [String:Bool] {
            self.myPets = myPets
        }
        if let roomIds = valueDictionary["roomIds"] as? [String:Bool] {
            self.roomIds = roomIds
        }
        if let unReadRoomIds = valueDictionary["unReadRoomIds"] as? [String:Bool] {
            self.unReadRoomIds = unReadRoomIds
        }
        if let todoRoomIds = valueDictionary["todoRoomIds"] as? [String:Bool] {
            self.todoRoomIds = todoRoomIds
        }
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
        
        print("DEBUG_PRINT: UserData.init end")
    }
}
