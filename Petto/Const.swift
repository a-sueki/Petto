//
//  Const.swift
//  Petto
//
//  Created by admin on 2017/06/29.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Foundation

struct Paths {
    static let PetPath = "pet"
    static let UserPath = "user"
    static let MessagePath = "message"
}

struct Environment {
    static let codes = ["code01","code02","code03","code04"]
    static let strings = ["室内のみ","エアコンあり","２部屋以上","庭あり"]
    static func toString(_ code:String) -> String {
        switch code {
        case codes[0] : return strings[0]
        case codes[1] : return strings[1]
        case codes[2] : return strings[2]
        case codes[3] : return strings[3]
        default:  return "不明"
        }
    }
    static func toCode(_ string:String) -> String {
        switch string {
        case strings[0] : return codes[0]
        case strings[1] : return codes[1]
        case strings[2] : return codes[2]
        case strings[3] : return codes[3]
        default:  return "不明"
        }
    }
    static func convertList(_ codeList: [String]) -> Set<String> {
        var nameList:Set<String> = []
        for code in codeList {
            nameList.insert(toString(code))
        }
        return nameList
    }
}

struct Tool {
    static let codes = ["code01","code02","code03","code04","code05","code06","code07"]
    static let strings = ["寝床","トイレ","首輪＆リード","ケージ","歯ブラシ","ブラシ","爪研ぎ","キャットタワー"]
    
    static func toString(_ code:String) -> String {
        switch code {
        case codes[0] : return strings[0]
        case codes[1] : return strings[1]
        case codes[2] : return strings[2]
        case codes[3] : return strings[3]
        case codes[4] : return strings[4]
        case codes[5] : return strings[5]
        case codes[6] : return strings[6]
        default:  return "不明"
        }
    }
    static func toCode(_ string:String) -> String {
        switch string {
        case strings[0] : return codes[0]
        case strings[1] : return codes[1]
        case strings[2] : return codes[2]
        case strings[3] : return codes[3]
        case strings[4] : return codes[4]
        case strings[5] : return codes[5]
        case strings[6] : return codes[6]
        default:  return "不明"
        }
    }
    static func convertList(_ codeList: [String]) -> Set<String> {
        var nameList:Set<String> = []
        for code in codeList {
            nameList.insert(toString(code))
        }
        return nameList
    }
}
struct PetNGs {
    static let codes = ["code01","code02","code03","code04","code05"]
    static let strings = ["Bad評価1つ以上","定時帰宅できない","一人暮らし","小児あり世帯","高齢者のみ世帯"]
    
    static func toString(_ code:String) -> String {
        switch code {
        case codes[0] : return strings[0]
        case codes[1] : return strings[1]
        case codes[2] : return strings[2]
        case codes[3] : return strings[3]
        case codes[4] : return strings[4]
        default:  return "不明"
        }
    }
    static func toCode(_ string:String) -> String {
        switch string {
        case strings[0] : return codes[0]
        case strings[1] : return codes[1]
        case strings[2] : return codes[2]
        case strings[3] : return codes[3]
        case strings[4] : return codes[4]
        default:  return "不明"
        }
    }
    static func convertList(_ codeList: [String]) -> Set<String> {
        var nameList:Set<String> = []
        for code in codeList {
            nameList.insert(toString(code))
        }
        return nameList
    }
}
struct UserNGs {
    static let codes = ["code01","code02","code03","code04"]
    static let strings = ["吠え癖","噛み癖","生まれたて","持病あり"]
    
    static func toString(_ code:String) -> String {
        switch code {
        case codes[0] : return strings[0]
        case codes[1] : return strings[1]
        case codes[2] : return strings[2]
        case codes[3] : return strings[3]
        default:  return "不明"
        }
    }
    static func toCode(_ string:String) -> String {
        switch string {
        case strings[0] : return codes[0]
        case strings[1] : return codes[1]
        case strings[2] : return codes[2]
        case strings[3] : return codes[3]
        default:  return "不明"
        }
    }
    static func convertList(_ codeList: [String]) -> Set<String> {
        var nameList:Set<String> = []
        for code in codeList {
            nameList.insert(toString(code))
        }
        return nameList
    }
}
