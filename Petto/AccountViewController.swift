//
//  AccountViewController.swift
//  Petto
//
//  Created by admin on 2017/08/29.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD
import CoreLocation

class AccountViewController: BaseFormViewController {
    
    let userDefaults = UserDefaults.standard
    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG_PRINT: AccountViewController.viewDidLoad start")
        
        // ログイン中かチェック
        if let _ = FIRAuth.auth()?.currentUser?.uid {
            // Formを表示
            self.updateUserData()
        }
        print("DEBUG_PRINT: AccountViewController.viewDidLoad end")
    }
    
    func updateUserData() {
        print("DEBUG_PRINT: AccountViewController.updateUserData start")
        
        // 必須入力チェック
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
            
        }
        ImageRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.textLabel?.textColor = .red
            }
        }
        
        // Cell初期設定
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }
        
        // フォーム
        form +++
            Section("Account") {
                $0.header = HeaderFooterView<AccountView>(.class)
            }
            
            <<< EmailRow("mail") {
                $0.title = "メールアドレス" 
                $0.value = userDefaults.string(forKey: DefaultString.Mail)
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChangeAfterBlurred
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
            //TODO:必須入力じゃダメ。入力項目から削除？
            <<< PasswordRow("password") {
                $0.title = "パスワード"
                $0.value = userDefaults.string(forKey: DefaultString.Password)
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6))
                $0.add(rule: RuleMaxLength(maxLength: 12))
                $0.validationOptions = .validatesOnChangeAfterBlurred
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
                $0.title = "ニックネーム"
                $0.placeholder = "Placeholder"
                $0.value = userDefaults.string(forKey: DefaultString.DisplayName)
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
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
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "OK"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: UserViewController.updateUserData \(error)のため処理は行いません")
                    }else{
                        self?.executePost()
                    }
        }
        print("DEBUG_PRINT: AccountViewController.updateUserData end")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: AccountViewController.executePost start")
        
        // HUDで処理中を表示
        SVProgressHUD.show()

        // アカウント情報の修正
        //TODO:ユーザーを再認証する
        for (key,value) in form.values() {
            if value == nil {
                print("ALERT::: key値「\(key)」がnilです。")
            }else if case let itemValue as String = value {
                // 表示名を設定する
                if key == "displayName" {
                    let user = FIRAuth.auth()?.currentUser
                    if let user = user {
                        let changeRequest = user.profileChangeRequest()
                        changeRequest.displayName = itemValue
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("DEBUG_PRINT: " + error.localizedDescription)
                            }
                            print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                            // HUDで完了を知らせる
                            SVProgressHUD.showSuccess(withStatus: "ニックネームを更新しました")
                        }
                    } else {
                        print("DEBUG_PRINT: ニックネームの設定に失敗しました。")
                    }
                    // メールアドレスを設定する
                }else if key == "mail" {
                    let user = FIRAuth.auth()?.currentUser
                    if let user = user {
                        user.updateEmail(itemValue, completion: { error in
                            if let error = error {
                                print("DEBUG_PRINT: " + error.localizedDescription)
                            }
                            print("DEBUG_PRINT: [email = \(user.email!)]の設定に成功しました。")
                            // HUDで完了を知らせる
                            SVProgressHUD.showSuccess(withStatus: "メールアドレスを更新しました")
                        })
                    } else {
                        print("DEBUG_PRINT: メールアドレスの設定に失敗しました。")
                    }
                    // パスワードを設定する
                }else if key == "password" {
                    let user = FIRAuth.auth()?.currentUser
                    if let user = user {
                        user.updatePassword(itemValue, completion: { error in
                            if let error = error {
                                print("DEBUG_PRINT: " + error.localizedDescription)
                            }
                            print("DEBUG_PRINT: パスワードの更新に成功しました。")
                            // HUDで完了を知らせる
                            SVProgressHUD.showSuccess(withStatus: "パスワードを更新しました")
                        })
                    } else {
                        print("DEBUG_PRINT: パスワードの設定に失敗しました。")
                    }
                }
            }
        }
        
        // UserDefaultsを更新
        userDefaults.set(self.inputData["mail"] , forKey: DefaultString.Mail)
        userDefaults.set(self.inputData["password"] , forKey: DefaultString.Password)
        userDefaults.set(self.inputData["displayName"] , forKey: DefaultString.DisplayName)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "アカウント情報を更新しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // HUDを消す
        SVProgressHUD.dismiss()

        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
        print("DEBUG_PRINT: AccountViewController.executePost start")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class AccountView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "mail"))
        imageView.frame = CGRect(x: 0, y: 10, width: 320, height: 100)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 120)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

