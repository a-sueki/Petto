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
    
    let userDefaults = UserDefaults.standard
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BookingViewController.viewDidLoad start")
        
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
            Section("おあずけ期間")
            <<< DateRow("startDate") {
                $0.title = "開始日付"
                $0.value = Date()
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
//                        cell.title?.textColor = .red
                    }
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
            //TODO: 開始日付以降のチェック
            <<< DateRow("endDate") {
                $0.title = "終了日付"
                $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
//                        cell.titleLabel?.textColor = .red
                    }
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
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "おあずけ期間をユーザーに提案する"
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.executePost()
        }
        
        print("DEBUG_PRINT: BookingViewController.viewDidLoad end")
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: BookingViewController.executePost start")
        
        for (key,value) in form.values() {
            if case let itemValue as Date = value {
                self.inputData["\(key)"] = itemValue.description
            }
        }
            
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = FIRAuth.auth()?.currentUser?.uid
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        
        //Firebaseに保存
/*        if let data = self.petData {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // update
            ref.child(Paths.PetPath).child(data.id!).updateChildValues(inputData)
        }else{
            let key = ref.child(Paths.PetPath).childByAutoId().key
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.PetPath).child(key).setValue(inputData)
            //ユーザのmyPetsIdを追加
            ref.child(Paths.UserPath).child(uid!).child("myPets").updateChildValues([key: true])
        }
 */       
        
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        print("DEBUG_PRINT: BookingViewController.executePost end")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
