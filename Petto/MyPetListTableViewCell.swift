//
//  MyPetListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class MyPetListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var footprintImageView: UIImageView!
    @IBOutlet weak var likeImageView: NSLayoutConstraint!
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
        print("MyPetListTableViewCell.setData:一覧表示中！！！！")
        
        self.photoImageView.image = petData.image
        self.nameLabel.text = petData.name

    }
    
    
}
