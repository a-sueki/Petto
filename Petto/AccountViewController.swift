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
import SCLAlertView

class AccountViewController: BaseFormViewController {
    
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: AccountViewController.viewDidLoad start")
        
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
          Section("アカウント情報")
            <<< EmailRow("mail") {
                $0.title = "メールアドレス"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Mail)
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
            <<< PasswordRow("password") {
                $0.title = "パスワード"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Password)
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6, msg: ErrorMsgString.RulePassword))
                $0.add(rule: RuleMaxLength(maxLength: 12, msg: ErrorMsgString.RulePassword))
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
                $0.title = "ニックネーム"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.DisplayName)
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
            +++ Section(){
                $0.hidden = .function([""], { form -> Bool in
                    if Auth.auth().currentUser == nil {
                        return false
                    }else{
                        return true
                    }
                })
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ログイン"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: AccountViewController.viewDidLoad \(error)のため処理は行いません")
                    }else{
                        self?.login()
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "アカウント作成"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: AccountViewController.viewDidLoad \(error)のため処理は行いません")
                    }else{
                        self?.displayEULA()
                    }
            }
            
            +++ Section(){
                $0.hidden = .function([""], { form -> Bool in
                    if Auth.auth().currentUser != nil {
                        return false
                    }else{
                        return true
                    }
                })
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "保存する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: AccountViewController.viewDidLoad \(error)のため処理は行いません")
                    }else{
                        self?.executeUpdate()
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "ログアウト"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0 {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: AccountViewController.viewDidLoad \(error)のため処理は行いません")
                    }else{
                        self?.logout()
                    }
        }
        
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "パスワードを忘れた場合"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.passwordReset()
        }
        

        print("DEBUG_PRINT: AccountViewController.viewDidLoad end")
    }
    
    @IBAction func displayEULA() {
        print("DEBUG_PRINT: AccountViewController.displayEULA start")
        
        if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            if let filePath = Bundle.main.path(forResource: "Policy", ofType: "txt"){
                if let data = NSData(contentsOfFile: filePath){
                    let eulaText = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
                    // ポップアップ表示
                    let alertView = SCLAlertView(appearance: SCLAlert.appearanceEULA)
                    // Creat the subview
                    let subview = UIView(frame: CGRect(x:0,y:0,width:216,height:100))
                    let x = (subview.frame.width - 200) / 2
                    // Add textfield 1
                    let textView = UITextView(frame: CGRect(x:x,y:0,width:200,height:100))
                    textView.layer.borderColor = UIColor.lightGray.cgColor
                    textView.layer.borderWidth = 0.5
                    textView.layer.cornerRadius = 3
                    textView.font = UIFont(name: "Helvetica", size: 10)
                    textView.isEditable = false
                    textView.text = eulaText
                    textView.textAlignment = NSTextAlignment.left
                    subview.addSubview(textView)
                    alertView.customSubview = subview
                    
                    alertView.addButton("同意します", target:self, selector:#selector(AccountViewController.createUser))
                    alertView.addButton("キャンセル", target:self, selector:#selector(AccountViewController.cancel))
                    alertView.showInfo("利用規約", subTitle: "")
                }else{
                    print("データなし")
                }
            }
        }else{
            self.createUser()
        }
        
        print("DEBUG_PRINT: AccountViewController.displayEULA end")
    }
    @objc func cancel(){
        print("DEBUG_PRINT: AccountViewController.cancel start")
        // なにもしない
        print("DEBUG_PRINT: AccountViewController.cancel end")
    }

    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func login(){
        print("DEBUG_PRINT: AccountViewController.login start")
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }
        
        let address = self.inputData["mail"] as! String
        let password = self.inputData["password"] as! String
        
        
        // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
        if address.characters.isEmpty || password.characters.isEmpty {
            SVProgressHUD.showError(withStatus: "ログイン情報を入力して下さい")
            return
        }else if isValidEmailAddress(emailAddressString: address) == false {
            SVProgressHUD.showError(withStatus: "メールアドレスが無効です")
            return
        }else if password.characters.count < 6 || password.characters.count > 12 {
            SVProgressHUD.showError(withStatus: "パスワードは6〜12文字にして下さい")
            return
        }
        
        Auth.auth().signIn(withEmail: address, password: password) { user, error in
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                SVProgressHUD.showError(withStatus: "ログインに失敗しました")
                return
            } else {
                print("DEBUG_PRINT: ログインに成功しました")
                
                // Firebaseから登録済みデータを取得
                if let uid = user?.user.uid {
                    SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                    let ref = Database.database().reference().child(Paths.UserPath).child(uid)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        print("DEBUG_PRINT: AccountViewController.login .observeSingleEventイベントが発生しました。")
                        if let _ = snapshot.value as? NSDictionary {
                            let userData = UserData(snapshot: snapshot, myId: uid)
                            
                            UserDefaults.standard.set(false , forKey: DefaultString.GuestFlag)
                            // ユーザーデフォルト設定（アカウント項目）
                            UserDefaults.standard.set(user?.user.uid , forKey: DefaultString.Uid)
                            UserDefaults.standard.set(address , forKey: DefaultString.Mail)
                            UserDefaults.standard.set(password , forKey: DefaultString.Password)
                            UserDefaults.standard.set(user?.user.displayName , forKey: DefaultString.DisplayName)
                            // ユーザーデフォルト設定（ユーザー項目（必須））
                            UserDefaults.standard.set(userData.sex , forKey: DefaultString.Sex)
                            UserDefaults.standard.set(userData.firstname , forKey: DefaultString.Firstname)
                            UserDefaults.standard.set(userData.lastname , forKey: DefaultString.Lastname)
                            UserDefaults.standard.set(userData.birthday , forKey: DefaultString.Birthday)
                            UserDefaults.standard.set(userData.area , forKey: DefaultString.Area)
                            UserDefaults.standard.set(userData.age , forKey: DefaultString.Age)
                            if userData.hasAnotherPet != nil {
                                UserDefaults.standard.set(userData.hasAnotherPet , forKey: DefaultString.HasAnotherPet)
                            }
                            if userData.isExperienced != nil {
                                UserDefaults.standard.set(userData.isExperienced , forKey: DefaultString.IsExperienced)
                            }
                            UserDefaults.standard.set(userData.option , forKey: DefaultString.Option)
                            UserDefaults.standard.set(userData.expectTo , forKey: DefaultString.ExpectTo)
                            UserDefaults.standard.set(userData.enterDetails , forKey: DefaultString.EnterDetails)
                            UserDefaults.standard.set(userData.createAt , forKey: DefaultString.CreateAt)
                            UserDefaults.standard.set(userData.createBy , forKey: DefaultString.CreateBy)
                            UserDefaults.standard.set(userData.updateAt , forKey: DefaultString.UpdateAt)
                            UserDefaults.standard.set(userData.updateBy , forKey: DefaultString.UpdateBy)
                            // ユーザーデフォルト設定（ユーザー項目（任意））
                            if !userData.ngs.isEmpty {
                                UserDefaults.standard.set(userData.ngs , forKey: DefaultString.Ngs)
                            }
                            if !userData.userEnvironments.isEmpty {
                                UserDefaults.standard.set(userData.userEnvironments , forKey: DefaultString.UserEnvironments)
                            }
                            if !userData.userTools.isEmpty {
                                UserDefaults.standard.set(userData.userTools , forKey: DefaultString.UserTools)
                            }
                            if !userData.userNgs.isEmpty {
                                UserDefaults.standard.set(userData.userNgs , forKey: DefaultString.UserNgs)
                            }
                            if userData.withSearch != nil {
                                UserDefaults.standard.set(userData.withSearch , forKey: DefaultString.WithSearch)
                            }
                            if !userData.myPets.isEmpty {
                                UserDefaults.standard.set(userData.myPets , forKey: DefaultString.MyPets)
                            }
                            if !userData.roomIds.isEmpty {
                                UserDefaults.standard.set(userData.roomIds , forKey: DefaultString.RoomIds)
                            }
                            if !userData.unReadRoomIds.isEmpty {
                                UserDefaults.standard.set(userData.unReadRoomIds , forKey: DefaultString.UnReadRoomIds)
                            }
                            if !userData.todoRoomIds.isEmpty {
                                UserDefaults.standard.set(userData.todoRoomIds , forKey: DefaultString.TodoRoomIds)
                            }
                            if !userData.goods.isEmpty {
                                UserDefaults.standard.set(userData.goods , forKey: DefaultString.Goods)
                            }
                            if !userData.bads.isEmpty {
                                UserDefaults.standard.set(userData.bads , forKey: DefaultString.Bads)
                            }
                            if !userData.historys.isEmpty {
                                UserDefaults.standard.set(userData.historys , forKey: DefaultString.Historys)
                            }
                            if userData.runningFlag != nil {
                                UserDefaults.standard.set(userData.runningFlag , forKey: DefaultString.RunningFlag)
                            }
                            // 違反は運営が参照するのみ。ブロックは、UserDefaultsのBlockedPetIds、BlockedUserIdsだけで、編集はブロック画面で行う。
                        }else{
                            UserDefaults.standard.set(true , forKey: DefaultString.GuestFlag)
                            // ユーザーデフォルト設定（アカウント項目）
                            UserDefaults.standard.set(user?.user.uid , forKey: DefaultString.Uid)
                            UserDefaults.standard.set(address , forKey: DefaultString.Mail)
                            UserDefaults.standard.set(password , forKey: DefaultString.Password)
                            UserDefaults.standard.set(user?.user.displayName , forKey: DefaultString.DisplayName)
                        }
                        DispatchQueue.main.async {
                            // 全てのモーダルを閉じる
                            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                            // HUDを消す
                            SVProgressHUD.dismiss()
                            // HOMEに画面遷移
                            let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
                            self.navigationController?.pushViewController(viewController2, animated: true)
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
                    }
                }else{
                    UserDefaults.standard.set(true , forKey: DefaultString.GuestFlag)
                }
            }
        }
        
        print("DEBUG_PRINT: AccountViewController.login end")
    }
    
    @objc func createUser(){
        print("DEBUG_PRINT: AccountViewController.createUser start")
        
        
        for (key,value) in form.values() {
            if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
            }
        }
        
        let address = self.inputData["mail"] as! String
        let password = self.inputData["password"] as! String
        let displayName = self.inputData["displayName"] as! String
        
        // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
        if address.characters.isEmpty || password.characters.isEmpty {
            SVProgressHUD.showError(withStatus: "ログイン情報を入力して下さい")
            return
        }else if isValidEmailAddress(emailAddressString: address) == false {
            SVProgressHUD.showError(withStatus: "メールアドレスが無効です")
            return
        }else if password.characters.count < 6 || password.characters.count > 12 {
            SVProgressHUD.showError(withStatus: "パスワードは6〜12文字にして下さい")
            return
        }
        
        // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
        Auth.auth().createUser(withEmail: address, password: password) { user, error in
            if let error = error {
                // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                print("DEBUG_PRINT: AcountViewController.createUser " + error.localizedDescription)
                if error.localizedDescription == "The email address is already in use by another account." {
                    SVProgressHUD.showError(withStatus: "そのアカウントは既に存在します")
                } else {
                    SVProgressHUD.showError(withStatus: "メールアドレスかパスワードが無効です")
                }
                return
            }
            
            // 確認メール送信
            if let user = Auth.auth().currentUser {
                if !user.isEmailVerified {
                    let alertVC = UIAlertController(title: "仮登録が成功しました", message: "上記アドレスに確認メールを送信しました。\nメール内のURLをクリックし、登録を完了してください。", preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "OK", style: .default) {
                        (_) in
                        user.sendEmailVerification(completion: nil)
                    }
                    let alertActionCancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                    alertVC.addAction(alertActionOkay)
                    alertVC.addAction(alertActionCancel)
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    // HUDで送信完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "アカウントを作成しました")
                }
            }
            
            let uid = Auth.auth().currentUser?.uid
            // ユーザーデフォルト設定（アカウント項目）
            UserDefaults.standard.set(true , forKey: DefaultString.GuestFlag)
            UserDefaults.standard.set(uid! , forKey: DefaultString.Uid)
            UserDefaults.standard.set(address , forKey: DefaultString.Mail)
            UserDefaults.standard.set(password , forKey: DefaultString.Password)
            UserDefaults.standard.set(displayName , forKey: DefaultString.DisplayName)
            UserDefaults.standard.removeObject(forKey: DefaultString.WithSearch)
            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("DEBUG_PRINT: AcountViewController.handleCreateAcountButton " + error.localizedDescription)
                    }
                    print("DEBUG_PRINT: AcountViewController.handleCreateAcountButton [displayName = \(user.displayName!)]の設定に成功しました。")
                }
            } else {
                print("DEBUG_PRINT: AcountViewController.handleCreateAcountButton displayNameの設定に失敗しました。")
            }
            
        }
        
        print("DEBUG_PRINT: AccountViewController.createUser end")
    }
    @IBAction func logout(){
        print("DEBUG_PRINT: AccountViewController.logout start")
        
        if UserDefaults.standard.string(forKey: DefaultString.Uid) != nil {
            let ref = Database.database().reference().child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!)
            ref.removeAllObservers()
            let ref2 = Database.database().reference().child(Paths.PetPath)
            ref2.removeAllObservers()
        }
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // HUDを消す
        SVProgressHUD.dismiss()
        
        // ログアウト
        do {
            try Auth.auth().signOut()
            // HOMEに画面遷移
            let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
            self.navigationController?.pushViewController(viewController2, animated: true)
            
        }catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        
        print("DEBUG_PRINT: AccountViewController.logout end")
    }
    
    @IBAction func passwordReset(){
        print("DEBUG_PRINT: AccountViewController.passwordReset start")
        
        self.view.endEditing(true)
        // PasswordResetに画面遷移
        let passwordResetViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordReset") as! PasswordResetViewController
        present(passwordResetViewController, animated: true, completion: nil)
        
        print("DEBUG_PRINT: AccountViewController.passwordReset end")
    }
    
    @IBAction func executeUpdate() {
        print("DEBUG_PRINT: AccountViewController.executeUpdate start")
        
        // アカウント情報の修正
        for (key,value) in form.values() {
            if value == nil {
                print("ALERT::: key値「\(key)」がnilです。")
            }else if case let itemValue as String = value {
                // 表示名を設定する
                if key == "displayName" {
                    if UserDefaults.standard.string(forKey: DefaultString.DisplayName) != itemValue {
                        // HUDで処理中を表示
                        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                        let user = Auth.auth().currentUser
                        if let user = user {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = itemValue
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    print("DEBUG_PRINT: " + error.localizedDescription)
                                    // HUDで完了を知らせる
                                    SVProgressHUD.showError(withStatus: "ニックネームの更新に失敗しました")
                                }
                                print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                                // ユーザーデフォルト設定（アカウント項目）
                                UserDefaults.standard.set(itemValue , forKey: DefaultString.DisplayName)
                                // HUDで完了を知らせる
                                SVProgressHUD.showSuccess(withStatus: "ニックネームを更新しました")
                            }
                        }
                    } else {
                        print("DEBUG_PRINT: ニックネーム変更なし")
                    }
                    // メールアドレスを設定する
                }else if key == "mail" {
                    if UserDefaults.standard.string(forKey: DefaultString.Mail) != itemValue {
                        // HUDで処理中を表示
                        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                        let user = Auth.auth().currentUser
                        if let user = user {
                            user.updateEmail(to: itemValue, completion: { error in
                                if let error = error {
                                    print("DEBUG_PRINT: " + error.localizedDescription)
                                    // HUDで完了を知らせる
                                    SVProgressHUD.showError(withStatus: "メールアドレスの更新に失敗しました")
                                }
                                print("DEBUG_PRINT: [email = \(user.email!)]の設定に成功しました。")
                                // ユーザーデフォルト設定（アカウント項目）
                                UserDefaults.standard.set(itemValue , forKey: DefaultString.Mail)
                                // HUDで完了を知らせる
                                SVProgressHUD.showSuccess(withStatus: "メールアドレスを更新しました")
                            })
                        } else {
                            print("DEBUG_PRINT: メールアドレス変更なし")
                        }
                    }
                    // パスワードを設定する
                }else if key == "password" {
                    if UserDefaults.standard.string(forKey: DefaultString.Password) != itemValue {
                        // HUDで処理中を表示
                        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                        let user = Auth.auth().currentUser
                        if let user = user {
                            user.updatePassword(to: itemValue, completion: { error in
                                if let error = error {
                                    print("DEBUG_PRINT: " + error.localizedDescription)
                                    // HUDで完了を知らせる
                                    SVProgressHUD.showError(withStatus: "パスワードの更新に失敗しました")
                                }
                                print("DEBUG_PRINT: パスワードの更新に成功しました。")
                                // ユーザーデフォルト設定（アカウント項目）
                                UserDefaults.standard.set(itemValue , forKey: DefaultString.Password)
                                // HUDで完了を知らせる
                                SVProgressHUD.showSuccess(withStatus: "パスワードを更新しました")
                            })
                        } else {
                            print("DEBUG_PRINT: パスワード変更なし")
                        }
                    }
                }
            }
        }
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: AccountViewController.viewWillDisappear start")
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child(Paths.UserPath).child(uid)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: AccountViewController.viewWillDisappear end")
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        print("DEBUG_PRINT: AccountViewController.isValidEmailAddress start")
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        print("DEBUG_PRINT: AccountViewController.isValidEmailAddress end")
        return  returnValue
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

