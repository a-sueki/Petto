//
//  ConsentViewController.swift
//  Petto
//
//  Created by admin on 2017/09/02.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD

class ConsentViewController: BaseFormViewController {
    
    var roomData: RoomData?
    var leaveData: LeaveData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    var inputData = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: ConsentViewController.viewDidLoad start")
        
        self.showLeaveData()
        
        print("DEBUG_PRINT: ConsentViewController.viewDidLoad end")
    }

    func showLeaveData() {
        print("DEBUG_PRINT: ConsentViewController.showLeaveData start")
        
        // フォーム
        form +++
            Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                if self.leaveData?.suggestFlag == true ,self.leaveData?.acceptFlag == false {
                    row.title = "以下の期間でペットあずかりを承諾する"
                 }else if self.leaveData?.acceptFlag == true {
                    row.title = "以下のおあずけ期間で承諾済み"
                    row.disabled = true
                }else if self.leaveData?.acceptFlag == false {
                    row.title = "以下のおあずけ期間で否認済み"
                    row.disabled = true
                }
                }.onCellSelection { [weak self] (cell, row) in
                    if self?.leaveData?.suggestFlag == true ,self?.leaveData?.acceptFlag == false {
                        row.section?.form?.validate()
                        self?.accept()
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.hidden = .function([], { form -> Bool in
                    if self.leaveData?.suggestFlag == true ,self.leaveData?.acceptFlag == false {
                        return false
                    }else{
                        return true
                    }
                })
                if self.leaveData?.suggestFlag == true ,self.leaveData?.acceptFlag == false {
                    row.title = "以下の期間でペットあずかりを否認する"
                }
                }.onCellSelection { [weak self] (cell, row) in
                        row.section?.form?.validate()
                        self?.deny()
            }
            <<< DateRow("startDate") {
                $0.title = "開始日付"
                if let dateString = self.leaveData?.startDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }
                $0.disabled = true
            }
            <<< DateRow("endDate") {
                $0.title = "終了日付"
                if let dateString = self.leaveData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }
                $0.disabled = true
        }
        
        print("DEBUG_PRINT: ConsentViewController.showLeaveData end")
    }

    @IBAction func deny() {
        print("DEBUG_PRINT: ConsentViewController.deny start")
        
        for (key,value) in form.values() {
            if value == nil {
                // Date
            }else if case let itemValue as Date = value {
                self.inputData["\(key)"] = DateCommon.dateToString(itemValue, dateFormat: DateCommon.dateFormat)
            }
        }
        var start = String(describing: self.inputData["startDate"]!)
        var end = String(describing: self.inputData["endDate"]!)
        start = start.substring(to: start.index(start.startIndex, offsetBy: 10))
        end = end.substring(to: end.index(end.startIndex, offsetBy: 10))

        self.inputData["suggestFlag"] = false
        let showMessage = "\(self.roomData?.petName! ?? "ペット")の飼い主さんにおあずけ期間の否認を通知しました"
        let sendText = "[自動送信メッセージ]\n以下のおあずかり日程は、\(self.roomData?.userName ?? "あずかり人")さんに否認されました。\n\(start)~\(end))"
        self.updateFIR(showMessage: showMessage, sendText: sendText)
        
        print("DEBUG_PRINT: ConsentViewController.deny start")
    }
    
    @IBAction func accept() {
        print("DEBUG_PRINT: ConsentViewController.accept start")
        
        for (key,value) in form.values() {
            if value == nil {
                // Date
            }else if case let itemValue as Date = value {
                self.inputData["\(key)"] = DateCommon.dateToString(itemValue, dateFormat: DateCommon.dateFormat)
            }
        }
        var start = String(describing: self.inputData["startDate"]!)
        var end = String(describing: self.inputData["startDate"]!)
        start = start.substring(to: start.index(start.startIndex, offsetBy: 10))
        end = end.substring(to: end.index(end.startIndex, offsetBy: 10))
        
        self.inputData["acceptFlag"] = true
        let showMessage = "\(self.roomData?.petName! ?? "ペット")の飼い主さんにおあずけ期間の承諾を通知しました"
        let sendText = "[自動送信メッセージ]\n以下のおあずかり日程で、\(self.roomData?.userName ?? "あずかり人")さんが承諾しました。\nペットの受け渡し時間・場所、当日の持ち物などを確認して下さい。\n\(start)~\(end))"
        self.updateFIR(showMessage: showMessage, sendText: sendText)

        print("DEBUG_PRINT: ConsentViewController.accept end")
    }

    func updateFIR(showMessage: String, sendText: String) {
        print("DEBUG_PRINT: ConsentViewController.updateFIR start")
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        
        // Messageを更新
        // Firebase連携用
        inputData["senderId"] = self.userDefaults?.string(forKey: DefaultString.Uid)
        inputData["senderDisplayName"] =  self.userDefaults?.string(forKey: DefaultString.DisplayName)!
        inputData["text"] = sendText
        inputData["timestamp"] = String(time)
        
        // insert
        let key = ref.child(Paths.MessagePath).child((self.roomData?.id)!).childByAutoId().key
        ref.child(Paths.MessagePath).child((self.roomData?.id)!).child(key).setValue(inputData)
        
        // update
        ref.child(Paths.RoomPath).child((self.roomData?.id)!).updateChildValues(["lastMessage" : sendText])
        ref.child(Paths.RoomPath).child((self.roomData?.id)!).updateChildValues(["updateAt" : String(time)])
        ref.child(Paths.UserPath).child((self.roomData?.userId)!).child("roomIds").updateChildValues([(self.roomData?.id)! : true])
        ref.child(Paths.PetPath).child((self.roomData?.petId)!).child("roomIds").updateChildValues([(self.roomData?.id)! : true])
        
        // 既読フラグupdate
        ref.child(Paths.RoomPath).child((self.roomData?.id)!).updateChildValues(["petOpenedFlg" : false])
        // ブリーダー（相手）の未読リストにroomIdを追加
        ref.child(Paths.UserPath).child((self.roomData?.breederId)!).child("unReadRoomIds").updateChildValues([(self.roomData?.id)! : true])
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: showMessage)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: ConsentViewController.updateFIR start")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
