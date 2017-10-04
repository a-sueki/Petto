//
//  HomeCollectionViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/04.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorageUI

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var daysNumLabel: UILabel!
    @IBOutlet weak var toolLabel: UILabel!
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var nameBackView: UIView!
    @IBOutlet weak var toDetailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //表示される時の値をセット
    func setPetData(petData: PetData) {
        print("DEBUG_PRINT: HomeCollectionViewCell.setPetData start")
        
        // 前回リロードで追加した帯があったら消す
        let subviews = self.petImageView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        //グラデーション
        let topColor = UIColor.clear
        let bottomColor =  UIColor.black
        let colorBottom = bottomColor.withAlphaComponent(0.7)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, colorBottom.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0 , width: self.frame.width, height: self.frame.width/149 * 49)
        self.nameBackView.layer.insertSublayer(gradientLayer, at: 0)
        self.contentView.bringSubview(toFront: self.nameLabel)
        self.contentView.bringSubview(toFront: self.areaLabel)

        // imageをstorageから直接ロード
        self.petImageView.sd_setImage(with: StorageRef.getRiversRef(key: petData.id!), placeholderImage: StorageRef.placeholderImage)
        self.nameLabel.text = "\(petData.name!)\n"
        if petData.age != nil {
            self.areaLabel.text = petData.area! + " | " +  petData.age!
        }else{
            self.areaLabel.text = petData.area!
        }
        // あずかり人募集中、かつ、終了日>今日
        if petData.isAvailable! && DateCommon.stringToDate(petData.endDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedDescending {
            if petData.minDays == petData.maxDays {
                self.termLabel.text = "\(DateCommon.displayShortDate(stringDate: petData.startDate!)) 〜 \(DateCommon.displayShortDate(stringDate: petData.endDate!))"
                self.daysNumLabel.text = "上の期間で\(String(petData.minDays!))日間"
            }else{
                self.termLabel.text = "\(DateCommon.displayShortDate(stringDate: petData.startDate!)) 〜 \(DateCommon.displayShortDate(stringDate: petData.endDate!))"
                self.daysNumLabel.text = "上の期間で\(String(petData.minDays!))〜\(String(petData.maxDays!))日間"
            }
        } else {
            self.termLabel.text = "現在、募集していません。"
            self.daysNumLabel.text = ""
            if self.petImageView.image != nil , self.petImageView.image != StorageRef.placeholderImage {
                // 帯を追加
                let bandLabel = UILabel(frame: CGRect(x: 0, y: self.frame.width/5 * 2, width: self.frame.width, height: self.frame.width/5))
                bandLabel.backgroundColor = UIColor.black
                bandLabel.alpha = 0.9
                bandLabel.font = UIFont(name: "Gill Sans", size: 15)
                bandLabel.text = "inative"
                bandLabel.textColor = UIColor.white
                bandLabel.textAlignment = NSTextAlignment.center
                self.petImageView.addSubview(bandLabel)
                
                // 写真をグレーアウト
                let myMonochromeFilter = CIFilter(name: "CIColorMonochrome")!
                myMonochromeFilter.setValue(CIImage(image: self.petImageView.image!), forKey: kCIInputImageKey)
                myMonochromeFilter.setValue(CIColor(red: 0.3, green: 0.3, blue: 0.3), forKey: kCIInputColorKey)
                myMonochromeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
                let myOutputImage : CIImage = myMonochromeFilter.outputImage!
                self.petImageView.image = UIImage(ciImage: myOutputImage)
            }
        }
        if petData.runningFlag != nil ,  petData.runningFlag! {
            // おあずけ中
            let bandLabel = UILabel(frame: CGRect(x: 0, y: self.frame.width/5 * 2, width: self.frame.width, height: self.frame.width/5))
            bandLabel.backgroundColor = UIColor.yellow
            bandLabel.alpha = 0.8
            bandLabel.font = UIFont(name: "Gill Sans", size: 15)
            bandLabel.text = "out now"
            bandLabel.textColor = UIColor.darkGray
            bandLabel.textAlignment = NSTextAlignment.center
            self.petImageView.addSubview(bandLabel)
        }

    
        print("DEBUG_PRINT: HomeCollectionViewCell.setPetData end")
    }

}
