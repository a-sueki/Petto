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
    static let SearchPath = "search"
}

struct DefaultString {
    static let Uid = "uid"
    static let Mail = "mail"
    static let Password = "password"
    static let DisplayName = "displayName"
    static let Phote = "phote"
    static let Area = "area"
}


struct Area {
    static let strings = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
}
struct Sex {
    static let strings = ["♂", "♀"]
    static let male = "♂"
    static let female = "♀"
}
struct Kind {
    static let strings = ["イヌ", "ネコ"]
    static let dog = "イヌ"
    static let cat = "ネコ"
}

struct CategoryDog {
    static let strings = ["雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
}
struct CategoryCat {
    static let strings = ["雑種","アビシニアン","アメリカンカール","アメリカンショートヘア","エキゾチックショートヘア","サイベリアン","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","ソマリ","ノルウェージャンフォレストキャット","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ベンガル","マンチカン","メインクーン","ラグドール","ロシアンブルー","不明"]
}

struct Age {
    static let strings = ["8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
}


struct Environment {
    static let codes = ["code01","code02","code03","code04"]
    //TODO: ユーザープロフィール画面表示用も作成する
    static let strings = ["室内のみ","エアコンあり","２部屋以上","庭あり"]
    static let icons = ["door","aircon","room","field"]
    
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
    static func toIcon(_ code:String) -> String {
        switch code {
        case codes[0] : return icons[0]
        case codes[1] : return icons[1]
        case codes[2] : return icons[2]
        case codes[3] : return icons[3]
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
    static let strings = ["吠え癖あり","噛み癖あり","生まれたて","持病あり"]
    
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
