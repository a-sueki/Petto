//
//  MyPetListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import FirebaseUI


class MyPetListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var outNowLabel: UILabel!
    @IBOutlet weak var isAvailableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //表示される時の値をセット
    func setData(petData: PetData) {
        

        self.photoImageView.sd_setImage(with: StorageRef.getRiversRef(key: petData.id!), placeholderImage: StorageRef.placeholderImage)
        // 写真を丸くする
        self.photoImageView.layer.cornerRadius = 40.0
        self.photoImageView.layer.masksToBounds = true

        self.nameLabel.text = petData.name
        
        if petData.isAvailable! {
            self.startDateLabel.text = "\(DateCommon.displayShortDate(stringDate: petData.startDate!)) 〜 \(DateCommon.displayShortDate(stringDate: petData.endDate!))"
            self.endDateLabel.text = "\(petData.minDays!)〜\(petData.maxDays!)日間"
        }else{
            self.startDateLabel.text = "設定されていません"
            self.endDateLabel.text = ""
        }
        
        // 期間外（あずかり人募集中ではない、もしくは、終了日 < 今日）
        if !petData.isAvailable! || DateCommon.stringToDate(petData.endDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
            if self.photoImageView.image != nil , self.photoImageView.image != StorageRef.placeholderImage {
                // 写真をグレーアウト
                let myMonochromeFilter = CIFilter(name: "CIColorMonochrome")!
                myMonochromeFilter.setValue(CIImage(image: self.photoImageView.image!), forKey: kCIInputImageKey)
                myMonochromeFilter.setValue(CIColor(red: 0.3, green: 0.3, blue: 0.3), forKey: kCIInputColorKey)
                myMonochromeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
                let myOutputImage : CIImage = myMonochromeFilter.outputImage!
                self.photoImageView.image = UIImage(ciImage: myOutputImage)
            }
        }
    }
}
