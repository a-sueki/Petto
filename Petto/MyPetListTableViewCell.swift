//
//  MyPetListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import FirebaseStorageUI


class MyPetListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var footprintImageView: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var todoImageView: UIImageView!
    @IBOutlet weak var historyImageView: UIImageView!
    

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
        self.nameLabel.text = petData.name

    }
    
    
}
