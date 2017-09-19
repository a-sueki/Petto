//
//  Const.swift
//  Petto
//
//  Created by admin on 2017/06/29.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Foundation
import SCLAlertView
import Firebase
import FirebaseDatabase

struct Paths {
    static let PetPath = "pet"
    static let UserPath = "user"
    static let MessagePath = "message"
    static let RoomPath = "room"
    static let SearchPath = "search"
    static let LeavePath = "leave"
    static let ContactPath = "contact"
}

struct DefaultString {
    // アカウント項目
    static let GuestFlag = "guestFlag"
    static let Uid = "uid"
    static let Mail = "mail"
    static let Password = "password"
    static let DisplayName = "displayName"
    // ユーザー項目（必須）
    static let Sex = "sex"
    static let Firstname = "firstname"
    static let Lastname = "lastname"
    static let Birthday = "birthday"
    static let Area = "area"
    static let Age = "age"
    static let HasAnotherPet = "hasAnotherPet"
    static let IsExperienced = "isExperienced"
    static let ExpectTo = "expectTo"
    static let EnterDetails = "enterDetails"
    static let CreateAt = "createAt"
    static let CreateBy = "createBy"
    static let UpdateAt = "updateAt"
    static let UpdateBy = "updateBy"
    // ユーザー項目（任意）
    static let Ngs = "ngs"
    static let UserEnvironments = "userEnvironments"
    static let UserTools = "userTools"
    static let UserNgs = "userNgs"
    static let WithSearch = "withSearch"
    static let MyPets = "myPets"
    static let RoomIds = "roomIds"
    static let UnReadRoomIds = "unReadRoomIds"
    static let TodoRoomIds = "todoRoomIds"
    static let Goods = "goods"
    static let Bads = "bads"
    static let Historys = "historys"
    static let RunningFlag = "runningFlag"
}

struct RandomImage {
    static let all = ["random1","random2","random3","random4","random5","random6","random7","random8","random9","random10","random11","random12","random13","random14","random15","random16","random17","random18","random19","random20","random21","random22","random23","random24","random25","random26","random27","random28","random29"]
    
    static func getRandomImage() -> UIImage {
        let index = Int(arc4random_uniform(UInt32(all.count)))
        return UIImage(named: all[index])!
    }
}

struct StorageRef{
    static let storage = FIRStorage.storage()
    static let storageRef = storage.reference(forURL: "gs://petto-5a42d.appspot.com/")
    static let placeholderImage = UIImage(named: "loading")

    static func getRiversRef(key: String) -> FIRStorageReference {
        let riversRef = storageRef.child("images/\(key).jpg")
        return riversRef
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

struct SelectString {
    static let unspecified = "選択してください"
}
struct SearchString {
    static let unspecified = "ALL"
}
struct Area {
    static let strings = [SelectString.unspecified,"北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    static let searchStrings = [SearchString.unspecified,"北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
}
struct Sex {
    static let strings = ["♂", "♀"]
    static let searchStrings = [SearchString.unspecified,"♂", "♀"]
    static let male = "♂"
    static let female = "♀"
    
}
struct UserSex {
    static let strings = ["男性", "女性"]
    static let male = "男性"
    static let female = "女性"
}

struct Size {
    static let strings = ["小型", "中型", "大型"]
    static let searchStrings = [SearchString.unspecified,"小型", "中型", "大型"]
    static let small = "小型"
    static let medium = "中型"
    static let large = "大型"
}
struct Color {
    static let codes = [Codes.C1,Codes.C2,Codes.C3,Codes.C4,Codes.C5,Codes.C6,Codes.C7,Codes.C8]
    static let strings = ["白","黒","灰","黄","茶","赤","青","紫"]
    static let icons = strings
    
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
    static func toIcon(_ code:String) -> UIImage {
        switch code {
        case codes[0] : return UIImage(named: icons[0])!
        case codes[1] : return UIImage(named: icons[1])!
        case codes[2] : return UIImage(named: icons[2])!
        case codes[3] : return UIImage(named: icons[3])!
        case codes[4] : return UIImage(named: icons[4])!
        case codes[5] : return UIImage(named: icons[5])!
        case codes[6] : return UIImage(named: icons[6])!
        case codes[7] : return UIImage(named: icons[7])!
        default: return UIImage()
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

struct Kind {
    static let strings = ["イヌ", "ネコ"]
    static let searchStrings = [SearchString.unspecified,"イヌ", "ネコ"]
    static let dog = "イヌ"
    static let cat = "ネコ"
}

struct CategoryDog {
    static let strings = ["雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
    static let searchStrings = [SearchString.unspecified,"雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
}

struct CategoryCat {
    static let strings = ["雑種","アビシニアン","アメリカンカール","アメリカンショートヘア","エキゾチックショートヘア","サイベリアン","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","ソマリ","ノルウェージャンフォレストキャット","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ベンガル","マンチカン","メインクーン","ラグドール","ロシアンブルー","不明"]
    static let searchStrings = [SearchString.unspecified,"雑種","アビシニアン","アメリカンカール","アメリカンショートヘア","エキゾチックショートヘア","サイベリアン","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","ソマリ","ノルウェージャンフォレストキャット","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ベンガル","マンチカン","メインクーン","ラグドール","ロシアンブルー","不明"]
}

struct Age {
    static let strings = ["8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
    static let searchStrings = [SearchString.unspecified,"8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
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

struct ConditionsColor {
    static let red = "-red"
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
    static func iconToCode(_ icon:String) -> String {
        switch icon {
        case icons[0] : return codes[0]
        case icons[1] : return codes[1]
        case icons[2] : return codes[2]
        case icons[3] : return codes[3]
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
    static let icons = ["doghouse","sandbox","dogchain","cage","toothbrush","brush","scratch","cattower"]
    
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
    static func iconToCode(_ icon:String) -> String {
        switch icon {
        case icons[0] : return codes[0]
        case icons[1] : return codes[1]
        case icons[2] : return codes[2]
        case icons[3] : return codes[3]
        case icons[4] : return codes[4]
        case icons[5] : return codes[5]
        case icons[6] : return codes[6]
        case icons[7] : return codes[7]
        default:  return "不明"
        }
    }
    static func toIcon(_ code:String) -> String {
        switch code {
        case codes[0] : return icons[0]
        case codes[1] : return icons[1]
        case codes[2] : return icons[2]
        case codes[3] : return icons[3]
        case codes[4] : return icons[4]
        case codes[5] : return icons[5]
        case codes[6] : return icons[6]
        case codes[7] : return icons[7]
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
    static let strings = ["Bad評価あり","定時帰宅NG","一人暮らし","小児がいる","高齢者のみ"]
    static let icons = ["nogood","timeout","absence","baby","aged"]
    
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
    static func iconToCode(_ icon:String) -> String {
        switch icon {
        case icons[0] : return codes[0]
        case icons[1] : return codes[1]
        case icons[2] : return codes[2]
        case icons[3] : return codes[3]
        case icons[4] : return codes[4]
        default:  return "不明"
        }
    }
    static func toIcon(_ code:String) -> String {
        switch code {
        case codes[0] : return icons[0]
        case codes[1] : return icons[1]
        case codes[2] : return icons[2]
        case codes[3] : return icons[3]
        case codes[4] : return icons[4]
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
    static let icons = ["howl","bite","born","hospital"]
    
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
    static func iconToCode(_ icon:String) -> String {
        switch icon {
        case icons[0] : return codes[0]
        case icons[1] : return codes[1]
        case icons[2] : return codes[2]
        case icons[3] : return codes[3]
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

struct ListSet {
    static func codeSet(codes: [String], new: [String:Bool]?, old: [String:Bool]?) -> [String:Bool] {
        var result = [String:Bool]()
        if old == nil || (old?.isEmpty)! {
            for code in codes {
                if new?[code] == true {
                    result[code] = true
                }else{
                    result[code] = false
                }
            }
        }else{
            for code in codes {
                if old?[code] == true, new?[code] == nil {
                    result[code] = false
                }else if old?[code] == true, new?[code] == true {
                    result[code] = true
                }else if old?[code] == false, new?[code] == nil {
                    result[code] = false
                }else if old?[code] == false, new?[code] == true {
                    result[code] = true
                }
            }
        }
        return result
    }
}

struct SCLAlert {
    
    static let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "Helvetica", size: 17)!,
        kTextFont: UIFont(name: "Helvetica", size: 14)!,
        kButtonFont: UIFont(name: "Helvetica", size: 14)!,
        showCloseButton: false
    )
}


