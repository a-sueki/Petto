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
    static let RoomPath = "room"
    static let SearchPath = "search"
    static let LeavePath = "leave"
}

struct DefaultString {
    // アカウント項目
    static let GuestFlag = "guestFlag"
    static let Uid = "uid"
    static let Mail = "mail"
    static let Password = "password"
    static let DisplayName = "displayName"
    // ユーザー項目（必須）
    static let ImageString = "imageString"
    static let Firstname = "firstname"
    static let Lastname = "lastname"
    static let Birthday = "birthday"
    static let Area = "area"
    static let Age = "age"
    static let HasAnotherPet = "hasAnotherPet"
    static let IsExperienced = "isExperienced"
    static let ExpectTo = "expectTo"
    static let CreateAt = "createAt"
    static let CreateBy = "createBy"
    static let UpdateAt = "updateAt"
    static let UpdateBy = "updateBy"
    // ユーザー項目（任意）
    static let Ngs = "ngs"
    static let UserEnvironments = "userEnvironments"
    static let UserTools = "userTools"
    static let UserNgs = "userNgs"
    static let MyPets = "myPets"
    static let RoomIds = "roomIds"
    static let UnReadRoomIds = "unReadRoomIds"
    static let TodoRoomIds = "todoRoomIds"
    static let Goods = "goods"
    static let Bads = "bads"
}

struct RandomImage {
    static let all = ["random1","random2","random3","random4","random5","random6","random7","random8","random9","random10","random11","random12","random13","random14","random15","random16","random17","random18","random19","random20","random21","random22","random23","random24","random25","random26","random27","random28","random29"]
    
    static func getRandomImage() -> UIImage {
        let index = Int(arc4random_uniform(UInt32(all.count)))
        return UIImage(named: all[index])!
    }
}


struct ErrorMsgString {
    static let RuleRequired = "必須入力です"
    static let RuleEmail = "不正なメールアドレスです"
    static let RuleURL = "不正なURLです"
    static let RuleGreaterThan = "値が小さすぎます"
    static let RuleGreaterOrEqualThan = "値が小さすぎます"
    static let RuleSmallerThan = "値が大きすぎます"
    static let RuleSmallerOrEqualThan = "値が大きすぎます"
    static let RuleMinLength = "文字数が最小値を下回っています"
    static let RuleMaxLength = "文字数が最大値を上回っています"
    static let RuleZipcodeLength = "郵便番号は7文字で入力して下さい"
    static let RuleEndDate = "開始日より未来の日付を入力して下さい"
    static let RuleMaxDate = "最短日数以下の値を入力して下さい"
    static let RulePassword = "パスワードは6~12文字で設定して下さい"
}

struct SearchString {
    static let unspecified = "指定しない"
}

struct Area {
    static let strings = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
}
struct SearchArea {
    static let strings = [SearchString.unspecified,"北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
}

struct Sex {
    static let strings = ["♂", "♀"]
    static let male = "♂"
    static let female = "♀"
}
struct SearchSex {
    static let strings = [SearchString.unspecified,"♂", "♀"]
    static let male = "♂"
    static let female = "♀"
}

struct Kind {
    static let strings = ["イヌ", "ネコ"]
    static let dog = "イヌ"
    static let cat = "ネコ"
}
struct SearchKind {
    static let strings = [SearchString.unspecified,"イヌ", "ネコ"]
    static let dog = "イヌ"
    static let cat = "ネコ"
}
struct CategoryDog {
    static let strings = ["雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
}
struct SearchCategoryDog {
    static let strings = [SearchString.unspecified,"雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
}

struct CategoryCat {
    static let strings = ["雑種","アビシニアン","アメリカンカール","アメリカンショートヘア","エキゾチックショートヘア","サイベリアン","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","ソマリ","ノルウェージャンフォレストキャット","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ベンガル","マンチカン","メインクーン","ラグドール","ロシアンブルー","不明"]
}
struct SearchCategoryCat {
    static let strings = [SearchString.unspecified,"雑種","アビシニアン","アメリカンカール","アメリカンショートヘア","エキゾチックショートヘア","サイベリアン","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","ソマリ","ノルウェージャンフォレストキャット","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ベンガル","マンチカン","メインクーン","ラグドール","ロシアンブルー","不明"]
}

struct Age {
    static let strings = ["8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
}
struct SearchAge {
    static let strings = [SearchString.unspecified,"8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
}

struct Codes {
    static let C1 = "code01"
    static let C2 = "code02"
    static let C3 = "code03"
    static let C4 = "code04"
    static let C5 = "code05"
    static let C6 = "code06"
    static let C7 = "code07"
    static let C8 = "code08"
}

struct Environment {
    static let codes = [Codes.C1,Codes.C2,Codes.C3,Codes.C4]
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
    static let codes = [Codes.C1,Codes.C2,Codes.C3,Codes.C4,Codes.C5,Codes.C6,Codes.C7,Codes.C8]
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
        case codes[7] : return strings[7]
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
        case strings[7] : return codes[7]
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
    static let codes = [Codes.C1,Codes.C2,Codes.C3,Codes.C4,Codes.C5]
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
    static let codes = [Codes.C1,Codes.C2,Codes.C3,Codes.C4]
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
