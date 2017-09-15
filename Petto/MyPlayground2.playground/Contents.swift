import UIKit

let start = "2017-09-16 13:55:01 +0900"

let y = start.substring(with: start.index(start.startIndex, offsetBy: 0)..<start.index(start.endIndex, offsetBy: -21))
print(y)

let m = start.substring(with: start.index(start.startIndex, offsetBy: 5)..<start.index(start.endIndex, offsetBy: -18))
print(m)

let d = start.substring(with: start.index(start.startIndex, offsetBy: 8)..<start.index(start.endIndex, offsetBy: -15))
print(d)

let h = start.substring(with: start.index(start.startIndex, offsetBy: 11)..<start.index(start.endIndex, offsetBy: -12))
print(h)

let mm = start.substring(with: start.index(start.startIndex, offsetBy: 14)..<start.index(start.endIndex, offsetBy: -9))
print(mm)

let a = Int(d)! - 1
print(a)
