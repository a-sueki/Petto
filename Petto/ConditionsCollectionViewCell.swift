//
//  ConditionsCollectionViewCell.swift
//  Petto
//
//  Created by admin on 2017/08/09.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class ConditionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //表示される時の値をセット
    func setPetData(key: String, codeList: [String]) {
        
        //TODO: textからiconをセット
        var nameList:Set<String> = []
        nameList = codeToString(key: key, codeList: codeList)
        /*
        self.iconImageView.image = UIImage(named: iconImageString)
        self.textLabel.text = text
        if red {
            self.iconImageView.image = UIImage(named: iconImageString)
            self.textLabel.textColor = UIColor.red
        }
 */
    }
    
    
    func codeToString(key: String ,codeList: [String]) -> Set<String>{
        var nameList:Set<String> = []
        switch key {
        case "environments" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("室内のみ")
                case "code02" : nameList.insert("エアコンあり")
                case "code03" : nameList.insert("２部屋以上")
                case "code04" : nameList.insert("庭あり")
                default: break
                }
            }
        case "tools" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("寝床")
                case "code02" : nameList.insert("トイレ")
                case "code03" : nameList.insert("ケージ")
                case "code04" : nameList.insert("歯ブラシ")
                case "code05" : nameList.insert("ブラシ")
                case "code06" : nameList.insert("爪研ぎ")
                case "code07" : nameList.insert("キャットタワー")
                default: break
                }
            }
        case "ngs" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("Bad評価1つ以上")
                case "code02" : nameList.insert("定時帰宅できない")
                case "code03" : nameList.insert("一人暮らし")
                case "code04" : nameList.insert("小児あり世帯")
                case "code05" : nameList.insert("高齢者のみ世帯")
                default: break
                }
            }
        default: break
        }
        return nameList
    }
    
    func codeToString2(key: String ,codeList: [String]) -> Set<String>{
        var nameList:Set<String> = []
        switch key {
        case "userEnvironments" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("室内飼いOK")
                case "code02" : nameList.insert("エアコンあり")
                case "code03" : nameList.insert("２部屋以上")
                case "code04" : nameList.insert("庭あり")
                default: break
                }
            }
        case "userTools" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("寝床")
                case "code02" : nameList.insert("トイレ")
                case "code03" : nameList.insert("ケージ")
                case "code04" : nameList.insert("歯ブラシ")
                case "code05" : nameList.insert("ブラシ")
                case "code06" : nameList.insert("爪研ぎ")
                case "code07" : nameList.insert("キャットタワー")
                default: break
                }
            }
        case "userNgs" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("吠え癖")
                case "code02" : nameList.insert("噛み癖")
                case "code03" : nameList.insert("生まれたて")
                case "code04" : nameList.insert("持病あり")
                default: break
                }
            }
        default: break
        }
        return nameList
    }
    
}
