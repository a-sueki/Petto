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
    var inputData = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: ConsentViewController.viewDidLoad start")
        
        // フォーム
        form +++
            Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                if self.leaveData?.suggestFlag == true ,self.leaveData?.acceptFlag == false {
                    row.title = "あずかりを承諾する"
                 }else if self.leaveData?.acceptFlag == true {
                    row.title = "以下あずかり期間で承諾済み"
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
                row.title = "あずかりを断る"
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

        print("DEBUG_PRINT: ConsentViewController.viewDidLoad end")
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
 
        // message作成
        let start = DateCommon.displayDate(stringDate: String(describing: self.inputData["startDate"]!))
        let end = DateCommon.displayDate(stringDate: String(describing: self.inputData["endDate"]!))
        let showMessage = "\(self.roomData?.petName! ?? "ペット")の飼い主さんに、おあずかりの否認を通知しました"
        let sendText = "[自動送信メッセージ]\n以下のおあずかり日程は、\(self.roomData?.userName ?? "あずかり人")さんに否認されました。\n\(start)~\(end)"
        let time = NSDate.timeIntervalSinceReferenceDate
        var inputData2 = [String : Any]()  //message
        inputData2["senderId"] = UserDefaults.standard.string(forKey: DefaultString.Uid)
        inputData2["senderDisplayName"] =  UserDefaults.standard.string(forKey: DefaultString.DisplayName)
        inputData2["text"] = sendText
        inputData2["timestamp"] = String(time)
        // massage送信＆更新
        let messagesViewController: MessagesViewController
        messagesViewController = MessagesViewController()
        messagesViewController.roomData = self.roomData
        messagesViewController.updateMessageData(inputData: inputData2, lastMessage: sendText)
        
        // leaveDataをdelete
        let ref = FIRDatabase.database().reference()
        ref.child(Paths.LeavePath).child((self.roomData?.id)!).removeValue()
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: showMessage)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
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
        // message作成
        let start = DateCommon.displayDate(stringDate: String(describing: self.inputData["startDate"]!))
        let end = DateCommon.displayDate(stringDate: String(describing: self.inputData["endDate"]!))
        let showMessage = "\(self.roomData?.petName! ?? "ペット")の飼い主さんに、おあずかりの承諾を通知しました"
        let sendText = "[自動送信メッセージ]\n以下のおあずかり日程で、\(self.roomData?.userName ?? "あずかり人")さんが承諾しました。\nペットの受け渡し時間・場所、当日の持ち物などを確認して下さい。\n\(start)~\(end)"
        let time = NSDate.timeIntervalSinceReferenceDate
        var inputData2 = [String : Any]()  //message
        inputData2["senderId"] = UserDefaults.standard.string(forKey: DefaultString.Uid)
        inputData2["senderDisplayName"] =  UserDefaults.standard.string(forKey: DefaultString.DisplayName)
        inputData2["text"] = sendText
        inputData2["timestamp"] = String(time)
        // massage送信＆更新
        let messagesViewController: MessagesViewController
        messagesViewController = MessagesViewController()
        messagesViewController.roomData = self.roomData
        messagesViewController.updateMessageData(inputData: inputData2, lastMessage: sendText)
        
        // leaveData,UserDataをupdate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(self.roomData!.id!)/acceptFlag/": true,
                            "/\(Paths.LeavePath)/\(self.roomData!.id!)/updateAt/": String(time),
                            "/\(Paths.UserPath)/\(self.roomData!.userId!)/todoRoomIds/\(self.roomData!.id!)/": true,
                            "/\(Paths.UserPath)/\(self.roomData!.breederId!)/todoRoomIds/\(self.roomData!.id!)/": true] as [String : Any]
        ref.updateChildValues(childUpdates)
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: showMessage)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)

        print("DEBUG_PRINT: ConsentViewController.accept end")
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
