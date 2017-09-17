import UIKit

let start = "2017-09-16 13:55:01 +0900"
let end = "2017-10-17 13:55:01 +0900"
let dateFormat = "yyyy-MM-dd HH:mm:ss Z"
func stringToDate(_ string:String, dateFormat: String ) -> Date {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter.date(from: string)!
}


func getIntervalDays(date:Date?,anotherDay:Date? = nil) -> Double {
    
    var retInterval:Double!
    
    if anotherDay == nil {
        retInterval = date?.timeIntervalSinceNow
    } else {
        retInterval = date?.timeIntervalSince(anotherDay!)
    }
    
    let ret = retInterval/86400
    
    return floor(ret)  // n日
}

let result = getIntervalDays(date: stringToDate(start,dateFormat: dateFormat), anotherDay: stringToDate(end,dateFormat: dateFormat))

print(result)
