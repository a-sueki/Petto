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
    static let ngicon = "-red"
    
    static func dateToString(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateCommon.dateFormat
        
        return dateFormatter.string(from: date)
    }
    
    static func stringToDate(_ string:String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateCommon.dateFormat
        
        return dateFormatter.date(from: string)!
    }
}
