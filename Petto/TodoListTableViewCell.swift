//
//  TodoListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/09/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class TodoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfile: UILabel!
    @IBOutlet weak var goodIntLabel: UILabel!
    @IBOutlet weak var badIntLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var willDoLabel: UILabel!
    @IBOutlet weak var isBreederLabel: UILabel!
    @IBOutlet weak var overdueLabel: UILabel!
    
    @IBOutlet weak var leaveInfoButton: UIButton!
    @IBOutlet weak var userDetailButton: UIButton!
    
    @IBOutlet weak var petDetailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 表示される時の値をセット
    func setData(leaveData: LeaveData) {
        print("TodoListTableViewCell.setData start")
        
        // 写真を丸くする
        self.userImageView.layer.cornerRadius = 25.0
        self.userImageView.layer.masksToBounds = true
        self.petImageView.layer.cornerRadius = 25.0
        self.petImageView.layer.masksToBounds = true
        
        // imageをstorageから直接ロード
        self.userImageView.sd_setImage(with: StorageRef.getRiversRef(key: leaveData.userId!), placeholderImage: StorageRef.placeholderImage)
        self.userNameLabel.text = leaveData.userName
        
        // 評価カウントをセット
        self.goodIntLabel.text = String(leaveData.userGoodInt ?? 0)
        self.badIntLabel.text = String(leaveData.userBadInt ?? 0)
        if leaveData.userAge == "秘密" {
            self.userProfile.text = leaveData.userArea! + " | " + leaveData.userSex!
        }else{
            self.userProfile.text = leaveData.userArea! + " | " + leaveData.userSex! + " | " + leaveData.userAge! + "才"
        }
        self.petImageView.sd_setImage(with: StorageRef.getRiversRef(key: leaveData.petId!), placeholderImage: StorageRef.placeholderImage)
        self.petNameLabel.text = leaveData.petName
        if leaveData.userId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            self.startDateLabel.text = "あずかり開始：" + DateCommon.displayDate(stringDate: leaveData.startDate!)
            self.endDateLabel.text = "あずかり終了：" + DateCommon.displayDate(stringDate: leaveData.endDate!)
        }else{
            self.startDateLabel.text = "おあずけ開始：" + DateCommon.displayDate(stringDate: leaveData.startDate!)
            self.endDateLabel.text = "おあずけ終了：" + DateCommon.displayDate(stringDate: leaveData.endDate!)
        }
        
        print("TodoListTableViewCell.setData start")
    }
}
