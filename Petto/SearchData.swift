//
//  SearchData.swift
//  Petto
//
//  Created by admin on 2017/08/23.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class SearchData: NSObject {
    var id: String?

    var lev11: Bool?
    var lev12: Bool?
    var lev21: Bool?
    var lev22: Bool?
    var lev23: Bool?
    var lev31: Bool?
    var lev32: Bool?

    // ペットプロフ
    var area: String?
    var kind: String?
    var age: String?
    var size: String?
    var sex: String?
    var color = [String:Bool]()
    // おあずけ条件
    var isAvailable: Bool?
    var toolRentalAllowed: Bool?
    var feedingFeePayable: Bool?
    var startDate: String?
    var endDate: String?
    var minDays: Int?
    var maxDays: Int?
    //状態
    var isVaccinated: Bool?
    var isCastrated: Bool?
    var wanted: Bool?
    var userNgs = [String:Bool]()
    
    // システム項目
    var createAt: NSDate?
    var createBy: String?
    var updateAt: NSDate?
    var updateBy: String?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        print("DEBUG_PRINT: SearchData.init start")
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.lev11 = valueDictionary["lev11"] as? Bool
        self.lev12 = valueDictionary["lev12"] as? Bool
        self.lev21 = valueDictionary["lev21"] as? Bool
        self.lev22 = valueDictionary["lev22"] as? Bool
        self.lev23 = valueDictionary["lev23"] as? Bool
        self.lev31 = valueDictionary["lev31"] as? Bool
        self.lev32 = valueDictionary["lev32"] as? Bool
        // ペットプロフ
        self.area = valueDictionary["area"] as? String
        self.kind = valueDictionary["kind"] as? String
        self.age = valueDictionary["age"] as? String
        self.size = valueDictionary["size"] as? String
        self.sex = valueDictionary["sex"] as? String
        if let color = valueDictionary["color"] as? [String:Bool] {
            self.color = color
        }
        // おあずけ条件
        self.isAvailable = valueDictionary["isAvailable"] as? Bool
        self.toolRentalAllowed = valueDictionary["toolRentalAllowed"] as? Bool
        self.feedingFeePayable = valueDictionary["feedingFeePayable"] as? Bool
        self.startDate = valueDictionary["startDate"] as? String
        self.endDate = valueDictionary["endDate"] as? String
        self.minDays = valueDictionary["minDays"] as? Int
        self.maxDays = valueDictionary["maxDays"] as? Int
        // 状態
        self.isVaccinated = valueDictionary["isVaccinated"] as? Bool
        self.isCastrated = valueDictionary["isCastrated"] as? Bool
        self.wanted = valueDictionary["wanted"] as? Bool
        if let userNgs = valueDictionary["userNgs"] as? [String:Bool] {
            self.userNgs = userNgs
        }
        // システム項目
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        self.createBy = valueDictionary["createBy"] as? String
        if let updateAt = valueDictionary["updateAt"] as? String {
            self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt)!)
            self.updateBy = valueDictionary["updateBy"] as? String
        }
        print("DEBUG_PRINT: SearchData.init end")
       
    }
}
