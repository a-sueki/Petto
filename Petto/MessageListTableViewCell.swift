//
//  MessageListTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //表示される時の値をセット
    func setData(petInfoData: PetInfoData, userData: UserData, messageData: MessageData) {
        print("MessageListTableViewCell.setData:一覧表示中！！！！")
/*        self.userImageView.image = userData.image
        self.userNameLabel.text = userData.firstname
        let goodNumber = userData.goods.count
        self.goodIntLabel.text = "\(goodNumber)"
        let badNumber = userData.bads.count
        self.badIntLabel.text = "\(badNumber)"
        self.userAreaLabel.text = userData.area
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: messageData.timestamp! as Date)
        self.sendTimeLabel.text = dateString
        self.messageLabel.text = messageData.text

        self.petImageView.image = petInfoData.image
        self.petNameLabel.text = petInfoData.name
*/
    }

}
