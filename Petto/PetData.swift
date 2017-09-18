//
//  PetData.swift
//  Petto
//
//  Created by admin on 2017/07/17.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class PetData: NSObject {
    var id: String?
    // ペット基本情報
    var name: String?
    var area: String?
    var sex: String?
    var size: String? //add
    var color = [String:Bool]() //add
    var enterDetails: Bool? // add
    var kind: String?
    var category: String?
    var age: String?
    var isVaccinated: Bool?
    var isCastrated: Bool?
    var wanted: Bool?
    var userNgs = [String:Bool]()
    // おあずけ条件
    var isAvailable: Bool?
    var toolRentalAllowed: Bool?    //add 道具レンタル可
    var feedingFeePayable: Bool?    //add エサ代支払い可
    var environments = [String:Bool]()
    var tools = [String:Bool]()
    var ngs = [String:Bool]()
    var feeding: String?
    var dentifrice: String?
    var walk: String?
    //おかずけ期間
    var startDate: String?
    var endDate: String?
    var minDays: Int?
    var maxDays: Int?
    var notices: String? //add
    // システム項目
    var createAt: NSDate?
    var createBy: String?
    var updateAt: NSDate?
    var updateBy: String?

    // EditView以外から更新
    // メッセージ情報
    var roomIds = [String:Bool]()
    // おあずけヒストリー
    var historys = [String:Bool]()
    // おあずけ中フラグ
    var runningFlag: Bool?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: PetData.init start")
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        // ペット基本情報
        self.area = valueDictionary["area"] as? String
        self.name = valueDictionary["name"] as? String
        self.kind = valueDictionary["kind"] as? String
        self.category = valueDictionary["category"] as? String
        self.sex = valueDictionary["sex"] as? String
        self.size = valueDictionary["size"] as? String
        if let color = valueDictionary["color"] as? [String:Bool] {
            self.color = color
        }
        self.enterDetails = valueDictionary["enterDetails"] as? Bool
        self.age = valueDictionary["age"] as? String
        self.isVaccinated = valueDictionary["isVaccinated"] as? Bool
        self.isCastrated = valueDictionary["isCastrated"] as? Bool
        self.wanted = valueDictionary["wanted"] as? Bool
        if let userNgs = valueDictionary["userNgs"] as? [String:Bool] {
            self.userNgs = userNgs
        }
        
        // おあずけ条件
        self.isAvailable = valueDictionary["isAvailable"] as? Bool
        self.toolRentalAllowed = valueDictionary["toolRentalAllowed"] as? Bool
        self.feedingFeePayable = valueDictionary["feedingFeePayable"] as? Bool
        
        if let environments = valueDictionary["environments"] as? [String:Bool] {
            self.environments = environments
        }
        if let tools = valueDictionary["tools"] as? [String:Bool] {
            self.tools = tools
        }
        if let ngs = valueDictionary["ngs"] as? [String:Bool] {
            self.ngs = ngs
        }
        self.feeding = valueDictionary["feeding"] as? String
        self.dentifrice = valueDictionary["dentifrice"] as? String
        self.walk = valueDictionary["walk"] as? String
        
        self.startDate = valueDictionary["startDate"] as? String
        self.endDate = valueDictionary["endDate"] as? String
        self.minDays = valueDictionary["minDays"] as? Int
        self.maxDays = valueDictionary["maxDays"] as? Int
        self.notices = valueDictionary["notices"] as? String
        
        // メッセージ情報
        if let roomIds = valueDictionary["roomIds"] as? [String:Bool] {
            self.roomIds = roomIds
        }
        if let historys = valueDictionary["historys"] as? [String:Bool] {
            self.historys = historys
        }
        self.runningFlag = valueDictionary["runningFlag"] as? Bool
        // システム項目
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        self.createBy = valueDictionary["createBy"] as? String
        if let updateAt = valueDictionary["updateAt"] as? String {
            self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt)!)
            self.updateBy = valueDictionary["updateBy"] as? String
        }
        print("DEBUG_PRINT: PetData.init end")
    }
}
