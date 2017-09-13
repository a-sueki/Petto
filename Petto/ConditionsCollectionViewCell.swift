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
    func setData(iconString: String, userData: UserData) {
        print("DEBUG_PRINT: ConditionsCollectionViewCell.setData start")
        
        let code1 = Environment.iconToCode(iconString)
        let code2 = Tool.iconToCode(iconString)
        let code3 = UserNGs.iconToCode(iconString)
        let code4 = PetNGs.iconToCode(iconString)
        
        if code1 != "不明" {
            if !userData.userEnvironments.isEmpty {
                for (key,val) in userData.userEnvironments {
                    if key == code1 && val == false {
                        let imageString = iconString + ConditionsColor.red
                        let code = Environment.iconToCode(iconString)
                        let text = Environment.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        self.textLabel.textColor = UIColor.red
                        break
                    }else if key == code1 && val == true {
                        let imageString = iconString
                        let code = Environment.iconToCode(iconString)
                        let text = Environment.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        break
                    }
                }
            }else{
                let imageString = iconString
                let code = Environment.iconToCode(iconString)
                let text = Environment.toString(code)
                self.iconImageView.image = UIImage(named: imageString)
                self.textLabel.text = text
            }
        }else if code2 != "不明" {
            if !userData.userTools.isEmpty {
                for (key,val) in userData.userTools {
                    if key == code2 && val == false {
                        let imageString = iconString + ConditionsColor.red
                        let code = Tool.iconToCode(iconString)
                        let text = Tool.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        self.textLabel.textColor = UIColor.red
                        break
                    }else if key == code2 && val == true {
                        let imageString = iconString
                        let code = Tool.iconToCode(iconString)
                        let text = Tool.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        break
                    }
                }
            }else{
                let imageString = iconString
                let code = Tool.iconToCode(iconString)
                let text = Tool.toString(code)
                self.iconImageView.image = UIImage(named: imageString)
                self.textLabel.text = text
            }
        }else if code3 != "不明" {
            if !userData.userNgs.isEmpty {
                for (key,val) in userData.userNgs {
                    if key == code3 && val == false {
                        let imageString = iconString + ConditionsColor.red
                        let code = UserNGs.iconToCode(iconString)
                        let text = UserNGs.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        self.textLabel.textColor = UIColor.red
                        break
                    }else if key == code3 && val == true {
                        let imageString = iconString
                        let code = UserNGs.iconToCode(iconString)
                        let text = UserNGs.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        break
                    }
                }
            }else{
                let imageString = iconString
                let code = UserNGs.iconToCode(iconString)
                let text = UserNGs.toString(code)
                self.iconImageView.image = UIImage(named: imageString)
                self.textLabel.text = text
            }
        }else if code4 != "不明" {
            if !userData.ngs.isEmpty {
                for (key,val) in userData.ngs {
                    if key == code4 && val == false {
                        let imageString = iconString + ConditionsColor.red
                        let code = PetNGs.iconToCode(iconString)
                        let text = PetNGs.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        self.textLabel.textColor = UIColor.red
                        break
                    }else if key == code4 && val == true {
                        let imageString = iconString
                        let code = PetNGs.iconToCode(iconString)
                        let text = PetNGs.toString(code)
                        self.iconImageView.image = UIImage(named: imageString)
                        self.textLabel.text = text
                        break
                    }
                }
            }else{
                let imageString = iconString
                let code = PetNGs.iconToCode(iconString)
                let text = PetNGs.toString(code)
                self.iconImageView.image = UIImage(named: imageString)
                self.textLabel.text = text
            }
        }
        
        // 条件指定がなかった場合
        if iconString == "no-data" {
            self.iconImageView.removeFromSuperview()
            self.textLabel.removeFromSuperview()
            
            let copyLabel = UILabel(frame: CGRect(x:(self.frame.size.width - 200) / 2, y:(self.frame.size.height - 20) / 2, width: 200, height: 20))
            copyLabel.text = "[指定されていません]"
            copyLabel.font = UIFont.systemFont(ofSize: 15)
            copyLabel.textColor = UIColor.black
            copyLabel.textAlignment = NSTextAlignment.center
            self.contentView.addSubview(copyLabel)
        }
        
        print("DEBUG_PRINT: ConditionsCollectionViewCell.setData end")
    }
}
