//
//  UserProfileViewController.swift
//  Petto
//
//  Created by admin on 2017/07/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD
import CoreLocation

class UserViewController: BaseFormViewController  {
    
    let userDefaults = UserDefaults.standard
    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    var inputData = [String : Any]()
    var inputData2 = [String : Any]() //userEnvironments
    var inputData3 = [String : Any]() //userTools
    var inputData4 = [String : Any]() //userNgs
    var inputData5 = [String : Any]() //ngs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG_PRINT: UserViewController.viewDidLoad start")
        
        // Firebaseから登録済みデータを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: UserViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                self.userData = UserData(snapshot: snapshot, myId: uid)

                self.userData?.mail = self.userDefaults.string(forKey: DefaultString.Mail)
                self.userData?.displayName = self.userDefaults.string(forKey: DefaultString.DisplayName)
                
                // Formを表示
                self.updateUserData()
            })
            // FIRDatabaseのobserveEventが上記コードにより登録されたため
            // trueとする
            observing = true
        }
        print("DEBUG_PRINT: UserViewController.viewDidLoad end")
    }
    
    func updateUserData() {
        print("DEBUG_PRINT: UserViewController.updateUserData start")
        
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
                if let _ = self.userData {
                    $0.header = HeaderFooterView<UserEditView>(.class)
                }else {
                    $0.header = HeaderFooterView<UserEntryView>(.class)
                }
            }
            
            <<< EmailRow("mail") {
                $0.title = "メールアドレス"
                $0.value = self.userData?.mail ?? nil
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
            //TODO:必須入力じゃダメ。入力項目から削除？
            <<< PasswordRow("password") {
                $0.title = "パスワード"
                $0.value = self.userData?.password ?? nil
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
            <<< AccountRow("displayName") {
                $0.title = "ニックネーム"
                $0.placeholder = "Placeholder"
                $0.value = self.userData?.displayName ?? nil
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
            
            
            //TODO: コミットメント＆小さなバッチ（メダル）
            +++ Section("プロフィール")
            <<< ImageRow("image"){
                $0.title = "写真"
                $0.baseValue = self.userData?.image ?? nil
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
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
            <<< NameRow("lastname") {
                $0.title = "姓"
                $0.value = self.userData?.lastname ?? nil
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
            <<< NameRow("firstname") {
                $0.title = "名"
                $0.value = self.userData?.firstname ?? nil
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
            <<< DateRow("birthday") {
                if let dateString = self.userData?.birthday {
                    $0.value = DateCommon.stringToDate(dateString)
                }else{
                    $0.value = DateCommon.stringToDate("1980-01-01 00:00:00 +000")
                }
                $0.title = "生年月日"
            }
            
            +++ Section("じゅうしょ")
            //TODO:入力中に赤字になる
            <<< ZipCodeRow("zipCode") {
                $0.title = "郵便番号"
                $0.placeholder = "1234567"
                $0.add(rule: RuleMinLength(minLength: 7))
                $0.add(rule: RuleMaxLength(maxLength: 7))
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
            <<< ButtonRow("search") { (row: ButtonRow) -> Void in
                row.title = "住所検索"
                }.onCellSelection { [weak self] (cell, row) in
                    if let code: RowOf<String> = self?.form.rowBy(tag: "zipCode"){
                        //TODO: 日本語対応＋市区町村まで。
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(code.value!, completionHandler: {(placemarks, error) -> Void in
                            if((error) != nil){
                                print("Error", error ?? "unknown...")
                            }
                            if let placemark = placemarks?.first {
                                print("State:       \(placemark.administrativeArea!)")
                                print("City:        \(placemark.locality!)")
                                print("SubLocality: \(placemark.subLocality!)")
                                // 住所ROW更新
                                self?.form.rowBy(tag: "address")?.baseValue = placemark.administrativeArea!
                                self?.form.rowBy(tag: "address")?.updateCell()
                                self?.form.rowBy(tag: "area")?.baseValue = placemark.administrativeArea!
                                self?.form.rowBy(tag: "area")?.updateCell()
                            }
                        })
                    }
            }
            
            <<< TextRow("address") {
                $0.title = "住所"
                $0.value = self.userData?.address ?? nil
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
            //TODO: 住所2入力欄
            
            <<< TextRow("area") {
                $0.title = "エリア"
                $0.value = self.userData?.area ?? nil
                $0.disabled = true
            }
            <<< PhoneRow("tel") {
                $0.title = "Tel"
                $0.value = self.userData?.tel ?? nil
                $0.placeholder = "09012345678"
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
            
            +++ Section("あなたのペット経験")
            <<< CheckRow("hasAnotherPet") {
                $0.title = "現在、他にペットを飼っている"
                $0.value = self.userData?.hasAnotherPet ?? false
            }
            <<< CheckRow("isExperienced") {
                $0.title = "過去、ペットを飼った経験がある"
                $0.value = self.userData?.isExperienced ?? false
            }
            //TODO: 「Bad評価1つ以上」は非表示。システムで判断する。
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "注意事項"
                $0.options = PetNGs.strings
                if let data = self.userData , data.ngs.count > 0 {
                    let codes = Array(data.ngs.keys)
                    $0.value = PetNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            
            +++ Section()
            <<< SwitchRow("expectTo"){
                $0.title = "ペットをあずかりたい"
                $0.value = self.userData?.expectTo ?? false
            }
            
            +++ Section("おあずかり環境"){
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
            }
            <<< MultipleSelectorRow<String>("userEnvironments") {
                $0.title = "飼養環境"
                //TODO:アイコン表示
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = Environment.strings
                if let data = self.userData , data.userEnvironments.count > 0 {
                    let codes = Array(data.userEnvironments.keys)
                    $0.value = Environment.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("userTools") {
                $0.title = "用意できる道具"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = Tool.strings
                if let data = self.userData , data.userTools.count > 0 {
                    let codes = Array(data.userTools.keys)
                    $0.value = Tool.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("userNgs") {
                $0.title = "NGペット"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = UserNGs.strings
                if let data = self.userData , data.userNgs.count > 0 {
                    let codes = Array(data.userNgs.keys)
                    $0.value = UserNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            //TODO:Petto利用履歴
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "OK"
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.executePost()
        }
        print("DEBUG_PRINT: UserViewController.updateUserData end")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func executePost() {
        print("---UserViewController.executePost start")
        
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
                            SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                        }
                    } else {
                        print("DEBUG_PRINT: 表示名の設定に失敗しました。")
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
                            SVProgressHUD.showSuccess(withStatus: "メールアドレスを変更しました")
                        })
                    } else {
                        print("DEBUG_PRINT: メールアドレスの設定に失敗しました。")
                    }
                    // メールアドレスを設定する
                }else if key == "password" {
                    let user = FIRAuth.auth()?.currentUser
                    if let user = user {
                        user.updatePassword(itemValue, completion: { error in
                            if let error = error {
                                print("DEBUG_PRINT: " + error.localizedDescription)
                            }
                            print("DEBUG_PRINT: passwordの設定に成功しました。")
                            // HUDで完了を知らせる
                            SVProgressHUD.showSuccess(withStatus: "パスワードを変更しました")
                        })
                    } else {
                        print("DEBUG_PRINT: パスワードの設定に失敗しました。")
                    }
                }
            }
        }
        
        // その他ユーザ情報
        for (key,value) in form.values() {
            if value == nil {
                print("ALERT::: key値「\(key)」がnilです。")
                //break
                // String
            }else if case let itemValue as String = value {
                self.inputData["\(key)"] = itemValue
                // UIImage
            }else if case let itemValue as UIImage = value {
                let imageData = UIImageJPEGRepresentation(itemValue , 0.5)
                let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
                self.inputData["imageString"] = imageString
                // Bool
            }else if case _ as Bool = value {
                self.inputData["\(key)"] = true
                // Date
            }else if case let itemValue as Date = value {
                self.inputData["\(key)"] = itemValue.description
                // Int
            }else if case let itemValue as Int = value {
                self.inputData["\(key)"] = itemValue
                // List
                // TODO: コード化。もっとスマートにできないか。
            }else {
                let fmap = (value as! Set<String>).flatMap({$0.components(separatedBy: ",")})
                switch key {
                case "userEnvironments" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case Environment.strings[0]: inputData2[Environment.codes[0]] = true
                        case Environment.strings[1]: inputData2[Environment.codes[1]] = true
                        case Environment.strings[2]: inputData2[Environment.codes[2]] = true
                        case Environment.strings[3]: inputData2[Environment.codes[3]] = true
                        default: break
                        }
                    }
                    self.inputData["userEnvironments"] = inputData2
                case "userTools" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case Tool.strings[0]: inputData3[Tool.codes[0]] = true
                        case Tool.strings[1]: inputData3[Tool.codes[1]] = true
                        case Tool.strings[2]: inputData3[Tool.codes[2]] = true
                        case Tool.strings[3]: inputData3[Tool.codes[3]] = true
                        case Tool.strings[4]: inputData3[Tool.codes[4]] = true
                        case Tool.strings[5]: inputData3[Tool.codes[5]] = true
                        case Tool.strings[6]: inputData3[Tool.codes[6]] = true
                        default: break
                        }
                    }
                    self.inputData["userTools"] = inputData3
                case "userNgs" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case UserNGs.strings[0]: inputData4[UserNGs.codes[0]] = true
                        case UserNGs.strings[1]: inputData4[UserNGs.codes[1]] = true
                        case UserNGs.strings[2]: inputData4[UserNGs.codes[2]] = true
                        case UserNGs.strings[3]: inputData4[UserNGs.codes[3]] = true
                        default: break
                        }
                    }
                    self.inputData["userNgs"] = inputData4
                case "ngs" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case PetNGs.strings[0]: inputData5[PetNGs.codes[0]] = true
                        case PetNGs.strings[1]: inputData5[PetNGs.codes[1]] = true
                        case PetNGs.strings[2]: inputData5[PetNGs.codes[2]] = true
                        case PetNGs.strings[3]: inputData5[PetNGs.codes[3]] = true
                        case PetNGs.strings[4]: inputData5[PetNGs.codes[4]] = true
                        default: break
                        }
                    }
                    self.inputData["ngs"] = inputData5
                default: break
                }
            }
        }
        
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        
        //Firebaseに保存
        if let data = self.userData {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // update
            ref.child(Paths.UserPath).child(data.id!).updateChildValues(self.inputData)
        }else{
            let key = uid//ref.child(Paths.UserPath).childByAutoId().key
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.UserPath).child(key!).setValue(self.inputData)
        }
        
        // UserDefaultsを更新
        userDefaults.set(uid , forKey: DefaultString.Uid)
        userDefaults.set(self.inputData["mail"] , forKey: DefaultString.Mail)
        userDefaults.set(self.inputData["password"] , forKey: DefaultString.Password)
        userDefaults.set(self.inputData["displayName"] , forKey: DefaultString.DisplayName)
        userDefaults.set(self.inputData["imageString"] , forKey: DefaultString.Phote)
        userDefaults.set(self.inputData["area"] , forKey: DefaultString.Area)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class UserViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class UserEditView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "userProfile"))
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

class UserEntryView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "userProfile"))
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
