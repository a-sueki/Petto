import UIKit

struct Codes {
    static let C1 = "code01"
    static let C2 = "code02"
    static let C3 = "code03"
    static let C4 = "code04"
    static let C5 = "code05"
    static let C6 = "code06"
    static let C7 = "code07"
}

let codes = [Codes.C1,Codes.C2,Codes.C3,Codes.C4]

//new
var a = [String:Bool]()
a[Codes.C2] = true
a[Codes.C3] = true

//old
var b = [String:Bool]()
b[Codes.C1] = false
b[Codes.C2] = false
b[Codes.C3] = true
b[Codes.C4] = true

//update
var c = [String:Bool]()


var hensu : String

for code in codes {
    if b[code] == nil, a[code] == nil {
        c[code] = false
    }else if b[code] == nil, a[code] == true {
        c[code] = true
        // old = ture, new = nil
    }else if b[code] == true, a[code] == nil {
        c[code] = false
        // old = true, new = true
    }else if b[code] == true, a[code] == true {
        c[code] = true
        // old = false, new = nil
    }else if b[code] == false, a[code] == nil {
        c[code] = false
        // old = false, new = true
    }else if b[code] == false, a[code] == true {
        c[code] = true
    }
}

for (k,v) in c {
    print(k)
    print(v)
}

