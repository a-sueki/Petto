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
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
/*    override func isSelected(_ selected: Bool, animated: Bool) {
        super.isSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
 */

    //表示される時の値をセット
    func setPostData(postData: PostData) {
        self.petImageView.image = postData.petImage
        self.areaLabel.text = postData.area!
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like")
            self.likeButton.setImage(buttonImage, for: UIControlState.selected)
        } else {
            let buttonImage = UIImage(named: "unlike")
            self.likeButton.setImage(buttonImage, for: UIControlState.normal)
        }
        
        /*let formatter = DateFormatter()
         formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
         formatter.dateFormat = "yyyy-MM-dd HH:mm"
         
         let dateString:String = formatter.string(from: postData.date! as Date)
         */
    }

}
