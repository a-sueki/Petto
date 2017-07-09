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
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var termLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //表示される時の値をセット
    func setPostData(postData: PostData) {
        self.petImageView.image = postData.petImage
        self.areaLabel.text = postData.area!
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        } else {
            let buttonImage = UIImage(named: "unlike")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        }
    }

}
