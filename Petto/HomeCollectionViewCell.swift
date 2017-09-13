//
//  HomeCollectionViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/04.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var kindImageView: UIImageView!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var termLabel: UILabel!
    
    @IBOutlet weak var toDetailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //表示される時の値をセット
    func setPetData(petData: PetData) {
        print("DEBUG_PRINT: HomeCollectionViewCell.setPetData start")
        
        self.petImageView.image = petData.image
        self.areaLabel.text = petData.area
        if petData.kind == "イヌ" {
            self.kindImageView.image = UIImage(named: "dog-lightgray")
        } else {
            self.kindImageView.image = UIImage(named: "cat-lightgray")
        }
        if petData.sex == "♂" {
            self.sexImageView.image = UIImage(named: "male-lightgray")
        } else {
            self.sexImageView.image = UIImage(named: "female-lightgray")
        }
        
        if petData.isAvailable! {
            if petData.minDays == petData.maxDays {
                self.termLabel.text = "期間：\(String(petData.minDays!))日間"
            }else{
                self.termLabel.text = "期間：\(String(petData.minDays!))〜\(String(petData.maxDays!))日間"
            }
        } else {
            self.termLabel.text = "期間外"
            // 写真をグレーアウト
            let myMonochromeFilter = CIFilter(name: "CIColorMonochrome")
            myMonochromeFilter?.setValue(CIImage(image: petData.image!), forKey: kCIInputImageKey)
            myMonochromeFilter?.setValue(CIColor(red: 0.3, green: 0.3, blue: 0.3), forKey: kCIInputColorKey)
            myMonochromeFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
            let myOutputImage : CIImage = myMonochromeFilter!.outputImage!
            self.petImageView.image = UIImage(ciImage: myOutputImage)
            // 再描画
//            self.petImageView.setNeedsDisplay()
            
            // 帯を追加
            let bandLabel = UILabel(frame: CGRect(x: 0, y: self.frame.width/5 * 2, width: self.frame.width, height: self.frame.width/5))
            bandLabel.backgroundColor = UIColor.black
            bandLabel.alpha = 0.9
            bandLabel.font = UIFont(name: "Gill Sans", size: 14)
            bandLabel.text = "During sleepover"
            bandLabel.textColor = UIColor.white
            bandLabel.textAlignment = NSTextAlignment.center
            self.petImageView.addSubview(bandLabel)
        }
        
        if petData.isLiked {
            let buttonImage = UIImage(named: "like-red")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        } else {
            let buttonImage = UIImage(named: "unlike")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        }
        
        print("DEBUG_PRINT: HomeCollectionViewCell.setPetData end")
    }
    
}
