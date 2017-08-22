//: Playground - noun: a place where people can play

import UIKit

let userDefaults = UserDefaults.standard
// デフォルト値
userDefaults.register(defaults: ["DataStore": "default"])


var str: String = userDefaults.object(forKey: "DataStore") as! String
print(str)


// Keyを指定して保存
userDefaults.set("qqq", forKey: "key")
userDefaults.synchronize()

// Keyを指定して読み込み
// Get the String from UserDefaults
if let myString = userDefaults.string(forKey: "key") {
    print("defaults savedString: \(myString)")
}


// Key の値を削除
//userDefaults.removeObject(forKey: "key")

// Keyを指定して読み込み
//str = userDefaults.object(forKey: "key") as! String
//print(str)


//UserDefaults.standard.string(forKey: "key")