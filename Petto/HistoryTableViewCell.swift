//
//  HistoryTableViewCell.swift
//  Petto
//
//  Created by admin on 2017/09/16.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import FirebaseStorageUI

//デリゲート先に適用してもらうプロトコル
protocol HistoryDelegate {
    func userCommentTextFeildDidEndEditing(cell:HistoryTableViewCell, value:String)
    func breederCommentTextFieldDidEndEditing(cell:HistoryTableViewCell, value:String)
}

class HistoryTableViewCell: UITableViewCell, UITextFieldDelegate  {

    var delegate:HistoryDelegate! = nil

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var termEndLabel: UILabel!
    
    @IBOutlet weak var noImageView: UILabel!
    @IBOutlet weak var photeImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var breederImageView: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var breederNameLabel: UILabel!
    
    @IBOutlet weak var cameraImageButton: UIButton!
    @IBOutlet weak var cameraLabelButton: UIButton!
    
    @IBOutlet weak var userCommentTextFeild: UITextField!
    @IBOutlet weak var breederCommentTextField: UITextField!
    
    @IBOutlet weak var userCommentSaveButton: UIButton!
    @IBOutlet weak var breederCommentSaveButton: UIButton!
    
    @IBOutlet weak var shearButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        userCommentTextFeild.delegate = self
        breederCommentTextField.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //デリゲートメソッド
    func userCommentTextFeildDidEndEditing(textField: UITextField) {
        //テキストフィールドから受けた通知をデリゲート先に流す。
        self.delegate.userCommentTextFeildDidEndEditing(cell: self, value:userCommentTextFeild.text!)
    }
    func breederCommentTextFieldDidEndEditing(textField: UITextField) {
        //テキストフィールドから受けた通知をデリゲート先に流す。
        self.delegate.breederCommentTextFieldDidEndEditing(cell: self, value:breederCommentTextField.text!)
    }
    
    
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを隠す
        textField.resignFirstResponder()
        return true
    }
    
    // TextField以外の部分をタッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("DEBUG_PRINT: HistoryTableViewCell.touchesBegan start")
        
        self.contentView.endEditing(true)
        
        print("DEBUG_PRINT: HistoryTableViewCell.touchesBegan end")
    }
    
    // 表示される時の値をセット
    func setData(leaveData: LeaveData) {
        print("HistoryTableViewCell.setData start")
        
        if leaveData.actualEndDate != nil {
            let dayNum = DateCommon.getIntervalDays(date: DateCommon.stringToDate(leaveData.actualEndDate!,dateFormat: DateCommon.dateFormat), anotherDay: DateCommon.stringToDate(leaveData.actualStartDate!,dateFormat: DateCommon.dateFormat))
            let start = DateCommon.displayDate(stringDate: leaveData.actualStartDate!)
            let end = DateCommon.displayDate(stringDate: leaveData.actualEndDate!)
            self.termLabel.text = "おあずけ開始：\(start)"
            self.termEndLabel.text = "おあずけ終了：\(end)（\(dayNum)日間）"
        }else{
            let dayNum = DateCommon.getIntervalDays(date: DateCommon.stringToDate(leaveData.endDate!,dateFormat: DateCommon.dateFormat), anotherDay: DateCommon.stringToDate(leaveData.actualStartDate!,dateFormat: DateCommon.dateFormat))
            let start = DateCommon.displayDate(stringDate: leaveData.actualStartDate!)
            let end = DateCommon.displayDate(stringDate: leaveData.endDate!)
            self.termLabel.text = "おあずけ開始：\(start)"
            self.termEndLabel.text = "おあずけ終了：\(end)（\(dayNum)日間）"
        }
        
        self.photeImageView.sd_setImage(with: StorageRef.getRiversRef(key: leaveData.id!), placeholderImage: StorageRef.placeholderImage)

        // 写真を丸くする
        self.userImageView.layer.cornerRadius = 25.0
        self.userImageView.layer.masksToBounds = true
        self.breederImageView.layer.cornerRadius = 25.0
        self.breederImageView.layer.masksToBounds = true
        
        // imageをstorageから直接ロード
        self.userImageView.sd_setImage(with: StorageRef.getRiversRef(key: leaveData.userId!), placeholderImage: StorageRef.placeholderImage)
        self.userImageView.sd_setImage(with: StorageRef.getRiversRef(key: leaveData.breederId!), placeholderImage: StorageRef.placeholderImage)
        
        self.userNameLabel.text = leaveData.userName
        self.breederNameLabel.text = "\(leaveData.petName)の飼い主さん"
        
        if leaveData.userComment != nil{
            self.userCommentTextFeild.text = leaveData.userComment
        }else{
            self.userCommentTextFeild.text = "[コメントはありません]"
        }
        if leaveData.breederComment != nil{
            self.breederCommentTextField.text = leaveData.breederComment
        }else{
            self.breederCommentTextField.text = "[コメントはありません]"
        }

        print("HistoryTableViewCell.setData end")
    }
}
