//
//  PetInfoData.swift
//  Petto
//
//  Created by admin on 2017/07/17.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class PetInfoData: NSObject {
    var id: String?
    // ペット基本情報
    var image: UIImage?
    var imageString: String?
    var name: String?
    var area: String?
    var sex: String?
    var kind: String?
    var category: String?
    var age: String?
    var isVaccinated: String?
    var isCastrated: String?
    var wanted: String?
    
    var isAvailable: String?
    var environments = [String:String]() // envID : true
    
    // システム項目
    var createAt: NSDate?
    var createBy: String?
    var updateAt: NSDate?
    var updateBy: String?
    // 評価
    var likes: [String] = []
    var isLiked: Bool = false
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        // ペット基本情報
        imageString = valueDictionary["imageString"] as? String
        self.image = UIImage(data: NSData(base64Encoded: imageString!, options: .ignoreUnknownCharacters)! as Data)
        self.area = valueDictionary["area"] as? String
        self.name = valueDictionary["name"] as? String
        self.kind = valueDictionary["kind"] as? String
        self.category = valueDictionary["category"] as? String
        self.sex = valueDictionary["sex"] as? String
        self.age = valueDictionary["age"] as? String
        self.isVaccinated = valueDictionary["isVaccinated"] as? String
        self.isCastrated = valueDictionary["isCastrated"] as? String
        self.wanted = valueDictionary["wanted"] as? String
        
        self.isAvailable = valueDictionary["isAvailable"] as? String
        if let environments = valueDictionary["environments"] as? [String:String] {
            self.environments = environments
        }

        
        // システム項目
        let createAt = valueDictionary["createAt"] as? String
        self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt!)!)
        self.createBy = valueDictionary["createBy"] as? String
        /*        let updateAt = valueDictionary["updateAt"] as? String
         self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
         self.updateBy = valueDictionary["updateBy"] as? String
         */

        // 評価
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        for followerId in self.likes {
            if followerId == myId {
                self.isLiked = true
                break
            }
        }
        
    }
}
