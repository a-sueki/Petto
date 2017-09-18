//
//  MessageListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class MessageListTableViewCell: UITableViewCell {

    let userDefaults = UserDefaults.standard
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfile: UILabel!
    
    @IBOutlet weak var goodIntLabel: UILabel!
    @IBOutlet weak var badIntLabel: UILabel!
    @IBOutlet weak var sendTimeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var petProfileButton: UIButton!
    @IBOutlet weak var messageLabelButton: UIButton!
    @IBOutlet weak var unReadLabel: UILabel!
    @IBOutlet weak var isBreederLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // 表示される時の値をセット
    func setData(roomData: RoomData) {
        print("MessageListTableViewCell.setData start")
        
        // 写真を丸くする
        self.userImageView.layer.cornerRadius = 25.0
        self.userImageView.layer.masksToBounds = true
        self.petImageView.layer.cornerRadius = 25.0
        self.petImageView.layer.masksToBounds = true
       
        // imageをstorageから直接ロード
        self.userImageView.sd_setImage(with: StorageRef.getRiversRef(key: roomData.userId!), placeholderImage: StorageRef.placeholderImage)
        self.userNameLabel.text = roomData.userName

        //　評価カウントをセット
        self.goodIntLabel.text = String(roomData.userGoodInt ?? 0)
        self.badIntLabel.text = String(roomData.userBadInt ?? 0)
        self.userProfile.text = roomData.userArea! + " | " + roomData.userSex! + " | " + roomData.userAge! + "才"
        self.petImageView.sd_setImage(with: StorageRef.getRiversRef(key: roomData.petId!), placeholderImage: StorageRef.placeholderImage)
        self.petNameLabel.text = roomData.petName
        
        self.sendTimeLabel.text = DateCommon.dateToString(roomData.updateAt! as Date, dateFormat: DateCommon.displayDateFormat)
        self.messageLabel.text = roomData.lastMessage
        
        print("MessageListTableViewCell.setData end")
    }
    
    

}
