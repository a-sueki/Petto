//
//  BookingViewController.swift
//  Petto
//
//  Created by admin on 2017/08/28.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD

class BookingViewController: BaseFormViewController {
    
    var roomData: RoomData?
    var leaveData: LeaveData?
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BookingViewController.viewDidLoad start")
        // Firebaseから登録済みデータを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if let roomId = self.roomData?.id {
                // 要素が追加されたら再表示
                let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(roomId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print("DEBUG_PRINT: BookingViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                    if let _ = snapshot.value as? NSDictionary {
                        
                        self.leaveData = LeaveData(snapshot: snapshot, myId: uid)
                        // Formを表示
                        self.showLeaveData()
                    }else{
                        // Formを表示
                        self.showLeaveData()
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
                
        print("DEBUG_PRINT: BookingViewController.viewDidLoad end")
    }
    
    func showLeaveData() {
        print("DEBUG_PRINT: BookingViewController.showLeaveData start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        // フォーム
        form +++
            Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                if let _ = self.leaveData, self.leaveData?.suggestFlag == true ,self.leaveData?.acceptFlag == false {
                    row.title = "以下のおあずけ期間で相手の承諾待ち"
                    row.disabled = true
                }else if self.leaveData?.acceptFlag == true {
                    row.title = "以下のおあずけ期間で承認されました"
                    row.disabled = true
                }else{
                    row.title = "以下のおあずけ期間を相手に提案する"
                }
                }.onCellSelection { [weak self] (cell, row) in
                    if self?.leaveData == nil || self?.leaveData?.suggestFlag == false{
                        row.section?.form?.validate()
                        self?.suggest()
                    }
            }
            <<< DateRow("startDate") {
                $0.title = "開始日付"
                if let _ = self.leaveData, self.leaveData?.suggestFlag == true {
                    $0.value = DateCommon.stringToDate((self.leaveData?.startDate)!, dateFormat: DateCommon.dateFormat)
                    $0.disabled = true
                }else{
                    $0.value = Date()
                }
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange { [weak self] row in
                    let endRow: DateRow! = self?.form.rowBy(tag: "endDate")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< DateRow("endDate") {
                $0.title = "終了日付"
                if let _ = self.leaveData, self.leaveData?.suggestFlag == true {
                    $0.value = DateCommon.stringToDate((self.leaveData?.endDate)!, dateFormat: DateCommon.dateFormat)
                    $0.disabled = true
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<Date>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleClosure { [weak self] row -> ValidationError? in
                    let startRow: DateRow! = self!.form.rowBy(tag: "startDate")
                    let endRow: DateRow! = self!.form.rowBy(tag: "endDate")
                    if startRow.value?.compare(endRow.value!) == .orderedDescending {
                        return ValidationError(msg: ErrorMsgString.RuleEndDate)
                    }
                    return nil
                })
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChange
                }.onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
        }
        
        print("DEBUG_PRINT: BookingViewController.showLeaveData end")
    }
    
    @IBAction func suggest() {
        print("DEBUG_PRINT: BookingViewController.suggest start")
        
        for (key,value) in form.values() {
            if value == nil {
                // Date
            }else if case let itemValue as Date = value {
                self.inputData["\(key)"] = DateCommon.dateToString(itemValue, dateFormat: DateCommon.dateFormat)
            }
        }
        
        self.inputData["suggestFlag"] = true
        self.inputData["acceptFlag"] = false
        self.inputData["completeFlag"] = false
        self.inputData["abortFlag"] = false
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = FIRAuth.auth()?.currentUser?.uid
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        
        //Firebaseに保存
        if let data = self.leaveData {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // update
            ref.child(Paths.LeavePath).child(data.id!).updateChildValues(inputData)
        }else{
            self.inputData["userId"] = self.roomData?.userId
            self.inputData["userName"] = self.roomData?.userName
            self.inputData["userImageString"] = self.roomData?.userImageString
            self.inputData["petId"] = self.roomData?.petId
            self.inputData["petName"] = self.roomData?.petName
            self.inputData["petImageString"] = self.roomData?.petImageString
            self.inputData["breederId"] = self.roomData?.breederId
            
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.LeavePath).child((self.roomData?.id)!).setValue(inputData)
        }
        var start = String(describing: self.inputData["startDate"]!)
        var end = String(describing: self.inputData["endDate"]!)
        start = start.substring(to: start.index(start.startIndex, offsetBy: 10))
        start = start.replacingOccurrences(of: "-", with: "/")
        end = end.substring(to: end.index(end.startIndex, offsetBy: 10))
        end = end.replacingOccurrences(of: "-", with: "/")

        // Messageを更新
        let text = "[自動送信メッセージ]\n以下の日程で、\(self.roomData?.petName ?? "ペット")の飼い主さんがおあずけ期間を提案しました。\n\(self.roomData?.userName ?? "あずかり人")さんは\"承認\"もしくは\"否認\"をタップして下さい。\n\(start)~\(end)"
        // Firebase連携用
        var inputDataMessage = [String : Any]()  //message
        inputDataMessage["senderId"] = UserDefaults.standard.string(forKey: DefaultString.Uid)
        inputDataMessage["senderDisplayName"] =  UserDefaults.standard.string(forKey: DefaultString.DisplayName)
        inputDataMessage["text"] = text
        inputDataMessage["timestamp"] = String(time)
        
        // insert
        let key = ref.child(Paths.MessagePath).child((self.roomData?.id)!).childByAutoId().key
        ref.child(Paths.MessagePath).child((self.roomData?.id)!).child(key).setValue(inputDataMessage)
        // update
        ref.child(Paths.RoomPath).child((self.roomData?.id)!).updateChildValues(["lastMessage" : text])
        ref.child(Paths.RoomPath).child((self.roomData?.id)!).updateChildValues(["updateAt" : String(time)])
        ref.child(Paths.UserPath).child((self.roomData?.userId)!).child("roomIds").updateChildValues([(self.roomData?.id)! : true])
        ref.child(Paths.PetPath).child((self.roomData?.petId)!).child("roomIds").updateChildValues([(self.roomData?.id)! : true])
        
        // 既読フラグupdate        
        ref.child(Paths.RoomPath).child((self.roomData?.id)!).updateChildValues(["userOpenedFlg" : false])
        // あずかり人（相手）の未読リストにroomIdを追加
        ref.child(Paths.UserPath).child((self.roomData?.userId)!).child("unReadRoomIds").updateChildValues([(self.roomData?.id)! : true])
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "\(self.roomData?.petName! ?? "ペット")の飼い主さんにおあずけ期間を提案しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
    
        print("DEBUG_PRINT: BookingViewController.suggest end")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
