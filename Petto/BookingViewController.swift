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
        
        self.showLeaveData()

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
                    row.title = "承諾待ち"
                    row.disabled = true
                }else if self.leaveData?.acceptFlag == true {
                    row.title = "承認済み"
                    row.disabled = true
                }else{
                    row.title = "この期間でペットおあずけを提案する"
                }
                }.onCellSelection { [weak self] (cell, row) in
                    if self?.leaveData == nil || self?.leaveData?.suggestFlag == false{
                        row.section?.form?.validate()
                        self?.suggest()
                    }
            }
            <<< DateTimeRow("startDate") {
                $0.title = "開始日付"
                if let _ = self.leaveData, self.leaveData?.suggestFlag == true {
                    $0.value = DateCommon.stringToDate((self.leaveData?.startDate)!, dateFormat: DateCommon.dateFormat)
                    $0.disabled = true
                }else{
                    $0.value = Date()
                }
                $0.minimumDate = Date()
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange { [weak self] row in
                    let endRow: DateTimeRow! = self?.form.rowBy(tag: "endDate")
                    if let _ = endRow.value, row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value! = Date(timeInterval: 60*60*24, since: row.value!)
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
            
            <<< DateTimeRow("endDate") {
                $0.title = "終了日付"
                if let _ = self.leaveData, self.leaveData?.suggestFlag == true {
                    $0.value = DateCommon.stringToDate((self.leaveData?.endDate)!, dateFormat: DateCommon.dateFormat)
                    $0.disabled = true
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.minimumDate = Date()
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<Date>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleClosure { [weak self] row -> ValidationError? in
                    let startRow: DateTimeRow! = self!.form.rowBy(tag: "startDate")
                    let endRow: DateTimeRow! = self!.form.rowBy(tag: "endDate")
                    if let _ = startRow.value, startRow.value?.compare(endRow.value!) == .orderedDescending {
                        return ValidationError(msg: ErrorMsgString.RuleEndDate)
                    }
                    return nil
                })
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChange
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
        
        print("DEBUG_PRINT: BookingViewController.showLeaveData end")
    }
    
    //完了を押すとピッカーを閉じる
    func toolBarBtnPush(sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
    
    @IBAction func suggest() {
        print("DEBUG_PRINT: BookingViewController.suggest start")
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "suggest" as NSObject,
            kFIRParameterItemID: "2" as NSObject
            ])

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
        let showMessage = "\(self.roomData?.userName! ?? "あずかり人")さんに、おあずけ期間を提案しました"
        let sendText = "[自動送信メッセージ]\n以下の日程で、\(self.roomData?.petName ?? "ペット")の飼い主さんがおあずけ期間を提案しました。\n\(self.roomData?.userName ?? "あずかり人")さんは\"承認\"もしくは\"否認\"をタップして下さい。\n\(start)~\(end)"
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
        messagesViewController.updateMessageData(inputData: inputData2, lastMessage: sendText, image: nil)
        
        // leaveDataをinsert
        self.inputData["userId"] = self.roomData?.userId
        self.inputData["userName"] = self.roomData?.userName
        self.inputData["userAge"] = self.roomData?.userAge
        self.inputData["userArea"] = self.roomData?.userArea
        self.inputData["userSex"] = self.roomData?.userSex
        self.inputData["userGoodInt"] = self.roomData?.userGoodInt
        self.inputData["userBadInt"] = self.roomData?.userBadInt
        self.inputData["petId"] = self.roomData?.petId
        self.inputData["petName"] = self.roomData?.petName
        self.inputData["breederId"] = self.roomData?.breederId
        self.inputData["suggestFlag"] = true
        self.inputData["acceptFlag"] = false
        self.inputData["runningFlag"] = false
        self.inputData["completeFlag"] = false
        self.inputData["stopFlag"] = false
        self.inputData["abortFlag"] = false
        self.inputData["updateAt"] = String(time)
        self.inputData["updateBy"] = UserDefaults.standard.string(forKey: DefaultString.Uid)
        self.inputData["createAt"] = String(time)
        self.inputData["createBy"] = UserDefaults.standard.string(forKey: DefaultString.Uid)
        // insert
        let ref = FIRDatabase.database().reference()
        let key = ref.child(Paths.LeavePath).childByAutoId().key
        ref.child(Paths.LeavePath).child(key).setValue(inputData)
        
        // roomのtodoに追加
        let ref2 = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.RoomPath)/\((self.roomData?.id)!)/todoRoomIds/\(key)/": true] as [String : Any]
        ref2.updateChildValues(childUpdates)

        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: showMessage)
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
