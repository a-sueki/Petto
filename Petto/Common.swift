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
    
}
