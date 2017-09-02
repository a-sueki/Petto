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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG_PRINT: UserViewController.viewDidLoad start")
        
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // Firebaseから登録済みデータを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: UserViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    self.userData = UserData(snapshot: snapshot, myId: uid)
                }
                // Formを表示
                self.updateUserData()
            })
            // FIRDatabaseのobserveEventが上記コードにより登録されたためtrueとする
            observing = true
        }
        
        // HUDを消す
        SVProgressHUD.dismiss()
        
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
            //TODO: コミットメント＆小さなバッチ（メダル）
            Section("プロフィール")
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
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = Area.strings
                $0.value = self.userData?.area ?? $0.options.first
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
            
            <<< DateRow("birthday") {
                $0.title = "生年月日"
                if let dateString = self.userData?.birthday {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = DateCommon.stringToDate("1980-01-01 00:00:00 +000", dateFormat: DateCommon.dateFormat)
                }
                $0.maximumDate = Date()
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { [weak self] (cell, row) in
                    let calendar = Calendar(identifier: .gregorian)
                    let bYear = calendar.component(.year, from: row.baseValue as! Date)
                    let bMonth = calendar.component(.month, from: row.baseValue as! Date)
                    let bDate = calendar.component(.day, from: row.baseValue as! Date)
                    let birthDate = DateComponents(calendar: calendar, year: bYear, month: bMonth, day: bDate).date!
                    let nYear = calendar.component(.year, from: Date())
                    let nMonth = calendar.component(.month, from: Date())
                    let nDate = calendar.component(.day, from: Date())
                    let now = DateComponents(calendar: calendar, year: nYear, month: nMonth, day: nDate).date!
                    let age = calendar.dateComponents([.year], from: birthDate, to: now).year!
                    // 年齢ROW更新
                    self?.form.rowBy(tag: "age")?.baseValue = age.description
                    self?.form.rowBy(tag: "age")?.updateCell()
            }
            
            <<< TextRow("age") {
                $0.title = "年齢"
                $0.value = self.userData?.age ?? nil
                $0.disabled = true
            }
            
            /*+++ Section("エリア")
             <<< ZipCodeRow("zipCode") {
             $0.title = "郵便番号"
             $0.value = self.userData?.zipCode ?? nil
             $0.placeholder = "1234567"
             $0.add(rule: RuleMinLength(minLength: 7, msg: ErrorMsgString.RuleZipcodeLength))
             $0.add(rule: RuleMaxLength(maxLength: 7, msg: ErrorMsgString.RuleZipcodeLength))
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
             //TODO:日本語に変換
             <<< ButtonRow("search") { (row: ButtonRow) -> Void in
             row.title = "エリア検索"
             }.onCellSelection { [weak self] (cell, row) in
             if let code: RowOf<String> = self?.form.rowBy(tag: "zipCode"){
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
             //self?.form.rowBy(tag: "address")?.baseValue = placemark.administrativeArea!
             //self?.form.rowBy(tag: "address")?.updateCell()
             // エリアROW更新
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
             */
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
                $0.title = "飼い主さんへの留意事項"
                $0.options = PetNGs.strings
                if let data = self.userData , data.ngs.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.ngs {
                        if val == true {
                            codes.append(key)
                        }
                    }
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
            //TODO:アイコン表示
            <<< MultipleSelectorRow<String>("userEnvironments") {
                $0.title = "飼養環境"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = Environment.strings
                if let data = self.userData , data.userEnvironments.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.userEnvironments {
                        if val == true {
                            codes.append(key)
                        }
                    }
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
                    var codes = [String]()
                    for (key,val) in data.userTools {
                        if val == true {
                            codes.append(key)
                        }
                    }
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
                    var codes = [String]()
                    for (key,val) in data.userNgs {
                        if val == true {
                            codes.append(key)
                        }
                    }
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
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: UserViewController.updateUserData \(error)のため処理は行いません")
                    }else{
                        self?.executePost()
                    }
        }
        print("DEBUG_PRINT: UserViewController.updateUserData end")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: UserViewController.executePost start")
        
        // ユーザ情報
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
            }else if case let v as Bool = value {
                switch key {
                case "expectTo": self.inputData["\(key)"] = boolSet(new: v ,old: self.userData?.expectTo)
                case "hasAnotherPet": self.inputData["\(key)"] = boolSet(new: v ,old: self.userData?.hasAnotherPet)
                case "isExperienced": self.inputData["\(key)"] = boolSet(new: v ,old: self.userData?.isExperienced)
                default: break
                }
                // Date
            }else if case let itemValue as Date = value {
                self.inputData["\(key)"] = itemValue.description
                // Int
            }else if case let itemValue as Int = value {
                self.inputData["\(key)"] = itemValue
                // List
            }else {
                let fmap = (value as! Set<String>).flatMap({$0.components(separatedBy: ",")})
                switch key {
                case "userEnvironments" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Environment.toCode(itemValue)] = true
                    }
                    self.inputData["userEnvironments"] = codeSet(codes: Environment.codes, new: codeArray, old: userData?.userEnvironments)
                case "userTools" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Tool.toCode(itemValue)] = true
                    }
                    self.inputData["userTools"] = codeSet(codes: Tool.codes, new: codeArray, old: userData?.userTools)
                case "userNgs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[UserNGs.toCode(itemValue)] = true
                    }
                    self.inputData["userNgs"] = codeSet(codes: UserNGs.codes, new: codeArray, old: self.userData?.userNgs)
                case "ngs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[PetNGs.toCode(itemValue)] = true
                    }
                    self.inputData["ngs"] = codeSet(codes: PetNGs.codes, new: codeArray, old: userData?.ngs)
                default: break
                }
            }
        }
        
        // 表示名（ニックネーム）を名前で更新
        // HUDで処理中を表示
        SVProgressHUD.show()
        let user = FIRAuth.auth()?.currentUser
        if let newName = self.inputData["firstname"] as? String, newName != userDefaults.string(forKey: DefaultString.DisplayName) {
            if let user = user {
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = newName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        // HUDで投稿完了を表示する
                        SVProgressHUD.showError(withStatus: "表示の設定に失敗しました。")
                    }
                    print("DEBUG_PRINT: [displayName = \(newName)]の設定に成功しました。")
                    // HUDで投稿完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
            } else {
                print("DEBUG_PRINT: ニックネーム変更なし")
            }
        }
        
        // HUDで処理中を表示
        SVProgressHUD.show()
        
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
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "プロフィールを更新しました")
        }else{
            let key = uid
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.UserPath).child(key!).setValue(self.inputData)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "プロフィールを作成しました")
        }
        
        
        // UserDefaultsを更新
        userDefaults.set(self.inputData["imageString"] , forKey: DefaultString.Phote)
        userDefaults.set(self.inputData["area"] , forKey: DefaultString.Area)
        userDefaults.set(self.inputData["firstname"] , forKey: DefaultString.DisplayName)
        userDefaults.set(self.inputData["age"], forKey: DefaultString.Age)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HUDを消す
        SVProgressHUD.dismiss()
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func boolSet(new: Bool, old: Bool?) -> Bool {
        var result = false
        if old == nil {
            if new == true {
                result = true
            }else{
                result = false
            }
        }else{
            result = new
        }
        return result
    }
    
    func codeSet(codes: [String], new: [String:Bool]?, old: [String:Bool]?) -> [String:Bool] {
        var result = [String:Bool]()
        if old == nil {
            for code in codes {
                if new?[code] == true {
                    result[code] = true
                }else{
                    result[code] = false
                }
            }
        }else{
            for code in codes {
                if old?[code] == true, new?[code] == nil {
                    result[code] = false
                }else if old?[code] == true, new?[code] == true {
                    result[code] = true
                }else if old?[code] == false, new?[code] == nil {
                    result[code] = false
                }else if old?[code] == false, new?[code] == true {
                    result[code] = true
                }
            }
        }
        return result
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
