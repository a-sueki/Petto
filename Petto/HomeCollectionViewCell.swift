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
        
        self.petImageView.image = petData.image
        self.areaLabel.text = petData.area ?? "未選択"
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
            self.termLabel.text = "期間：\(String(petData.minDays!))〜\(String(petData.maxDays!))days"
        }
        if petData.isLiked {
            let buttonImage = UIImage(named: "like-red")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        } else {
            let buttonImage = UIImage(named: "unlike")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        }
    }

}
