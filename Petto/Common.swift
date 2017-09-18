//
//  Common.swift
//  Petto
//
//  Created by admin on 2017/08/25.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Foundation

struct DateCommon {
    static let dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    static let displayDateFormat = "yyyy-MM-dd HH:mm"
    static let sendTextDateFormat = "yyyy/MM/dd"
    static let ngicon = "-red"

    static func dateToString(_ date:Date, dateFormat: String ) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: date)
    }
    
    static func stringToDate(_ string:String, dateFormat: String ) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: string)!
    }
    
    static func displayDate(stringDate: String) -> String {
        
        let result = stringDate.substring(to: stringDate.index(stringDate.startIndex, offsetBy: 16))
        
        return result
    }
    
    static func displayShortDate(stringDate: String) -> String {
        
        let result = stringDate.substring(to: stringDate.index(stringDate.startIndex, offsetBy: 10))
        
        return result
    }
    
    static func getIntervalDays(date:Date?,anotherDay:Date? = nil) -> Double {
        
        var retInterval:Double!
        
        if anotherDay == nil {
            retInterval = date?.timeIntervalSinceNow
        } else {
            retInterval = date?.timeIntervalSince(anotherDay!)
        }
        let ret = retInterval/86400
        
        return floor(ret)  // n日
    }

}
