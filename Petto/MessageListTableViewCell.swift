//
//  MessageListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class MessageListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var goodIntLabel: UILabel!
    @IBOutlet weak var badIntLabel: UILabel!
    @IBOutlet weak var userAreaLabel: UILabel!
    @IBOutlet weak var sendTimeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var messageLabelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // 表示される時の値をセット
    func setData(userData: UserData, roomData: RoomData) {
        print("MessageListTableViewCell.setData start")
        
        self.userImageView.image = userData.image
        self.userNameLabel.text = userData.displayName
        //TODO: 評価カウントをセット
        self.goodIntLabel.text = "10" //String(userData.goods.count)
        self.badIntLabel.text = "3" //String(userData.bads.count)
        self.userAreaLabel.text = userData.area
        self.petImageView.image = roomData.petImage
        self.petNameLabel.text = roomData.petName
        self.sendTimeLabel.text = DateCommon.dateToString(roomData.updateAt! as Date)
        self.messageLabel.text = roomData.lastMessage
        
        print("MessageListTableViewCell.setData end")
    }
    
    

}
