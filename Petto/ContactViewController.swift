//
//  ContactViewController.swift
//  Petto
//
//  Created by admin on 2017/09/19.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD

class ContactViewController: BaseFormViewController {

    var contactData: ContactData?
    var inputData = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: ContactViewController.viewDidLoad start")
        
        // Cell初期設定
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        // フォーム
        form +++
            Section("お問い合わせ")
            <<< EmailRow("mail") {
                $0.title = "メールアドレス"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Mail) ?? nil
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnBlur
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
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
            <<< AccountRow("displayName") {
                $0.title = "お名前"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.DisplayName) ?? nil
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnBlur
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
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
            <<< TextAreaRow("text") {
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 100)
                $0.placeholder = "お問い合わせ、ご意見など"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnBlur
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
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "送信"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0{
                        print("DEBUG_PRINT: ContactViewController.send \(error)のため処理は行いません")
                    }else{
                        self?.sendMessage()
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "キャンセル"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.cancel()
        }
        
        print("DEBUG_PRINT: ContactViewController.viewDidLoad end")
    }

    @IBAction func sendMessage(){
        print("DEBUG_PRINT: ContactViewController.sendMessage start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }
        let time = NSDate.timeIntervalSinceReferenceDate
        if let uid = UserDefaults.standard.string(forKey: DefaultString.Uid) {
            self.inputData["createBy"] = uid
        }else{
            self.inputData["createBy"] = "guest"
        }
        self.inputData["createAt"] = String(time)
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        let key = ref.child(Paths.ContactPath).childByAutoId().key
        ref.child(Paths.ContactPath).child(key).setValue(self.inputData)

        SVProgressHUD.show(RandomImage.getRandomImage(), status: "ありがとうございます。\nお問い合わせを受け付けました。\n\n迅速に対応致します!")
        SVProgressHUD.dismiss(withDelay: 3)
                
        print("DEBUG_PRINT: ContactViewController.sendMessage start")
    }
    
    @IBAction func cancel(){
        print("DEBUG_PRINT: ContactViewController.cancel start")

        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
        print("DEBUG_PRINT: ContactViewController.cancel start")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
