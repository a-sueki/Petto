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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //表示される時の値をセット
    func setPetInfoData(petInfoData: PetInfoData) {
        // TODO: nilチェック
        
        self.petImageView.image = petInfoData.image
        self.areaLabel.text = petInfoData.area ?? "未選択"
        if petInfoData.kind == "イヌ" {
            self.kindImageView.image = UIImage(named: "dog-lightgray")
        } else {
            self.kindImageView.image = UIImage(named: "cat-lightgray")
        }
        if petInfoData.sex == "♂" {
            self.sexImageView.image = UIImage(named: "male-lightgray")
        } else {
            self.sexImageView.image = UIImage(named: "female-lightgray")
        }
        self.termLabel.text = "期間：\(String(petInfoData.minDays!))〜\(String(petInfoData.maxDays!))days"

        if petInfoData.isLiked {
            let buttonImage = UIImage(named: "like-red")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        } else {
            let buttonImage = UIImage(named: "unlike")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        }
    }

}
