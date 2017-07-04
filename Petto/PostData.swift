//
//  PostData.swift
//  Petto
//
//  Created by admin on 2017/06/29.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    var id: String?
//    var image: UIImage?
//    var imageString: String?
    var petImage: UIImage?
    var petImageString: String?
    var name: String?
    var kind: String?
    var area: String?
    var age: String?
    var date: NSDate?
    var likes: [String] = []
    var isLiked: Bool = false
    var isVaccinated: Bool?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        petImageString = valueDictionary["petImage"] as? String
        petImage = UIImage(data: NSData(base64Encoded: petImageString!, options: .ignoreUnknownCharacters)! as Data)
        
        self.name = valueDictionary["name"] as? String
        
        self.kind = valueDictionary["kind"] as? String
        self.area = valueDictionary["area"] as? String
        self.age = valueDictionary["age"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = NSDate(timeIntervalSinceReferenceDate: TimeInterval(time!)!)

        self.isVaccinated = valueDictionary["isVaccinated"] as? Bool
        
        
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        
        for likeId in self.likes {
            if likeId == myId {
                self.isLiked = true
                break
            }
        }

    }
}
