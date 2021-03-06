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
import FirebaseUI
import SVProgressHUD
import CoreLocation
import Toucan

class UserViewController: BaseFormViewController  {
    
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: UserViewController.viewDidLoad start")
        if UserDefaults.standard.string(forKey: DefaultString.GuestFlag) != nil {
            self.showForm()
        }else{
            SVProgressHUD.showError(withStatus: "エラーが発生しました。ログインし直して下さい")
        }
        print("DEBUG_PRINT: UserViewController.viewDidLoad end")
    }
    
    func showForm(){
        print("DEBUG_PRINT: UserViewController.showForm start")
        
        if UserDefaults.standard.object(forKey: DefaultString.RunningFlag) != nil,
            UserDefaults.standard.bool(forKey: DefaultString.RunningFlag) == true {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "おあずけ中は更新できません")
        }
        
        
        let view = UIImageView()
        if !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            view.sd_setImage(with: StorageRef.getRiversRef(key: UserDefaults.standard.string(forKey: DefaultString.Uid)!), placeholderImage: StorageRef.placeholderImage)
        }
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
            Section(footer: "プロフィールは、あなたがメッセージを送ったペットの飼い主さんにのみ公開されます。（姓、生年月日は非公開）") {
                if !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
                    $0.header = HeaderFooterView<UserEditView>(.class)
                }else {
                    $0.header = HeaderFooterView<UserEntryView>(.class)
                }
            }
            //TODO: コミットメント＆小さなバッジ（メダル）
            <<< ImageRow("image"){
                $0.title = "写真"
                $0.baseValue = view.image ?? nil
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "camera-1")
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
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Lastname) ?? nil
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
            <<< NameRow("firstname") {
                $0.title = "名"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Firstname) ?? nil
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
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = UserSex.strings
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Sex) ?? $0.options?.last
            }
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = Area.strings
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Area) ?? $0.options.first
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
            +++ Section("オプション")
            <<< SwitchRow("option"){
                $0.title = "年齢を登録する"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.Option)
            }
            <<< DateRow("birthday") {
                $0.hidden = .function(["option"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "option")
                    return row.value ?? false == false
                })
                $0.title = "生年月日"
                if let dateString = UserDefaults.standard.string(forKey: DefaultString.Birthday) {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = DateCommon.stringToDate("1980-01-01 00:00:00 +000", dateFormat: DateCommon.dateFormat)
                }
                $0.maximumDate = Date()
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
                $0.hidden = .function(["option"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "option")
                    return row.value ?? false == false
                })
                $0.title = "年齢"
                $0.value = UserDefaults.standard.string(forKey: DefaultString.Age) ?? nil
                $0.disabled = true
            }
            
            +++ Section()
            <<< SwitchRow("expectTo"){
                $0.title = "ペットをあずかりたい"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.ExpectTo)
            }
            
            +++ Section("あなたの環境（任意）"){
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
                if UserDefaults.standard.object(forKey: DefaultString.UserEnvironments) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.UserEnvironments)! {
                        if val as! Bool == true {
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
                if UserDefaults.standard.object(forKey: DefaultString.UserTools) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.UserTools)!{
                        if val as! Bool == true {
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
                if UserDefaults.standard.object(forKey: DefaultString.UserNgs) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.UserNgs)! {
                        if val as! Bool == true {
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
            <<< SwitchRow("enterDetails"){
                $0.title = "より詳細なプロフィールを入力する"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.EnterDetails)
            }
            
            +++ Section("あなたのペット経験など（任意）"){
                $0.hidden = .function(["enterDetails"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    return row.value ?? false == false
                })
            }
            <<< CheckRow("hasAnotherPet") {
                $0.title = "現在、他にペットを飼っている"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.HasAnotherPet)
            }
            <<< CheckRow("isExperienced") {
                $0.title = "過去、ペットを飼ったことがある"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.IsExperienced)
            }
            //TODO: 「Bad評価1つ以上」は非表示。システムで判断する。
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "飼い主さんへの留意事項"
                $0.options = PetNGs.strings
                if UserDefaults.standard.object(forKey: DefaultString.Ngs) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.Ngs)! {
                        if val as! Bool == true {
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
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                if UserDefaults.standard.object(forKey: DefaultString.RunningFlag) != nil,
                    UserDefaults.standard.bool(forKey: DefaultString.RunningFlag) == true {
                    row.title = "おあずけ中は更新できません"
                    row.disabled = true
                }else{
                    row.title = "保存する"
                }
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: UserViewController.updateUserData \(error)のため処理は行いません")
                    }else{
                        if UserDefaults.standard.object(forKey: DefaultString.RunningFlag) != nil,
                            UserDefaults.standard.bool(forKey: DefaultString.RunningFlag) == true {
                            SVProgressHUD.show(RandomImage.getRandomImage(), status: "おあずけ中は更新できません")
                        }else{
                            self?.executePost()
                        }
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "もどる"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.back()
        }
        
        print("DEBUG_PRINT: UserViewController.showForm end")
    }
    
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: UserViewController.executePost start")
        
        var photeImage: UIImage?
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
                photeImage = Toucan(image: itemValue).resize(CGSize(width: 200, height: 200), fitMode: Toucan.Resize.FitMode.clip).image
                // Bool
            }else if case let v as Bool = value {
                switch key {
                case "enterDetails": self.inputData["\(key)"] = boolSet(new: v ,old: UserDefaults.standard.bool(forKey: DefaultString.EnterDetails))
                case "option": self.inputData["\(key)"] = boolSet(new: v ,old: UserDefaults.standard.bool(forKey: DefaultString.Option))
                case "expectTo": self.inputData["\(key)"] = boolSet(new: v ,old: UserDefaults.standard.bool(forKey: DefaultString.ExpectTo))
                case "hasAnotherPet": self.inputData["\(key)"] = boolSet(new: v ,old: UserDefaults.standard.bool(forKey: DefaultString.HasAnotherPet))
                case "isExperienced": self.inputData["\(key)"] = boolSet(new: v ,old: UserDefaults.standard.bool(forKey: DefaultString.IsExperienced))
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
                    self.inputData["userEnvironments"] = ListSet.codeSet(codes: Environment.codes, new: codeArray, old: UserDefaults.standard.dictionary(forKey: DefaultString.UserEnvironments) as? [String : Bool])
                case "userTools" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Tool.toCode(itemValue)] = true
                    }
                    self.inputData["userTools"] = ListSet.codeSet(codes: Tool.codes, new: codeArray, old: UserDefaults.standard.dictionary(forKey: DefaultString.UserTools) as? [String : Bool])
                case "userNgs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[UserNGs.toCode(itemValue)] = true
                    }
                    self.inputData["userNgs"] = ListSet.codeSet(codes: UserNGs.codes, new: codeArray, old: UserDefaults.standard.dictionary(forKey: DefaultString.UserNgs) as? [String : Bool])
                case "ngs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[PetNGs.toCode(itemValue)] = true
                    }
                    self.inputData["ngs"] = ListSet.codeSet(codes: PetNGs.codes, new: codeArray, old: UserDefaults.standard.dictionary(forKey: DefaultString.Ngs) as? [String : Bool])
                default: break
                }
            }
        }
        
        // 表示名（ニックネーム）を名前で更新
        let user = Auth.auth().currentUser
        if let newName = self.inputData["firstname"] as? String,
            newName != UserDefaults.standard.string(forKey: DefaultString.DisplayName){
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = newName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        // HUDで投稿完了を表示する
                        SVProgressHUD.showError(withStatus: "表示の設定に失敗しました。")
                    }
                    print("DEBUG_PRINT: [displayName = \(newName)]の設定に成功しました。")
                    // UserDefaultsを更新（アカウント項目）
                    UserDefaults.standard.set(self.inputData["firstname"] , forKey: DefaultString.DisplayName)
                    // HUDで投稿完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "表示名を\(newName)に変更しました")
                }
            } else {
                print("DEBUG_PRINT: ニックネーム変更なし")
            }
        }
        
        // 生年月日・年齢をオプション化対応
        if inputData["age"] == nil {
            self.inputData["age"] = "秘密"
            self.inputData["birthday"] = "1980-01-01 00:00:00 +0000"
        }
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = Auth.auth().currentUser?.uid
        
        // 辞書を作成
        let ref = Database.database().reference()
        
        //Firebaseに保存
        if !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // remove（任意項目のみ）
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("userEnvironments").removeValue()
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("userTools").removeValue()
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("userNgs").removeValue()
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("hasAnotherPet").removeValue()
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("isExperienced").removeValue()
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("ngs").removeValue()
            // user更新
            ref.child(Paths.UserPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).updateChildValues(self.inputData)
            storageUpload(photeImage: photeImage!, key: uid!)
            
            // room更新
            var roomUpdateData1 = [String : Any]()
            if UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds) != nil {
                for (roomId,_) in UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)! {
                    roomUpdateData1["\(Paths.RoomPath)/\(roomId)/userName"] = inputData["firstname"]
                    roomUpdateData1["\(Paths.RoomPath)/\(roomId)/userArea"] = inputData["area"]
                    roomUpdateData1["\(Paths.RoomPath)/\(roomId)/userAge"] = inputData["age"]
                    roomUpdateData1["\(Paths.RoomPath)/\(roomId)/userSex"] = inputData["sex"]
                    roomUpdateData1["\(Paths.RoomPath)/\(roomId)/updateAt"] = inputData["updateAt"]
                }
                if !roomUpdateData1.isEmpty{
                    ref.updateChildValues(roomUpdateData1)
                }
            }
            
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "プロフィールを更新しました")
        }else{
            let key = uid
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.UserPath).child(key!).setValue(self.inputData)
            storageUpload(photeImage: photeImage!, key: key!)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "プロフィールを作成しました")
        }
        
        // UserDefaultsを更新（ユーザー項目）
        UserDefaults.standard.set(false, forKey: DefaultString.GuestFlag)
        UserDefaults.standard.set(self.inputData["sex"] , forKey: DefaultString.Sex)
        UserDefaults.standard.set(self.inputData["lastname"] , forKey: DefaultString.Lastname)
        UserDefaults.standard.set(self.inputData["firstname"] , forKey: DefaultString.Firstname)
        UserDefaults.standard.set(self.inputData["area"] , forKey: DefaultString.Area)
        UserDefaults.standard.set(self.inputData["birthday"] , forKey: DefaultString.Birthday)
        UserDefaults.standard.set(self.inputData["age"] , forKey: DefaultString.Age)
        UserDefaults.standard.set(self.inputData["hasAnotherPet"] , forKey: DefaultString.HasAnotherPet)
        UserDefaults.standard.set(self.inputData["isExperienced"] , forKey: DefaultString.IsExperienced)
        UserDefaults.standard.set(self.inputData["ngs"] , forKey: DefaultString.Ngs)
        UserDefaults.standard.set(self.inputData["option"] , forKey: DefaultString.Option)
        UserDefaults.standard.set(self.inputData["expectTo"] , forKey: DefaultString.ExpectTo)
        UserDefaults.standard.set(self.inputData["enterDetails"] , forKey: DefaultString.EnterDetails)
        UserDefaults.standard.set(self.inputData["userEnvironments"] , forKey: DefaultString.UserEnvironments)
        UserDefaults.standard.set(self.inputData["userTools"] , forKey: DefaultString.UserTools)
        UserDefaults.standard.set(self.inputData["userNgs"] , forKey: DefaultString.UserNgs)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
        print("DEBUG_PRINT: UserViewController.executePost end")
    }
    
    @IBAction func back() {
        print("DEBUG_PRINT: UserViewController.back start")
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
        print("DEBUG_PRINT: UserViewController.back end")
    }
    
    func storageUpload(photeImage: UIImage, key: String){
        
        if let data = UIImageJPEGRepresentation(photeImage, 0.25) {
            StorageRef.getRiversRef(key: key).putData(data , metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Image Uploaded Error")
                    print(error!)
                } else {
                    print("Image Uploaded Succesfully")
                }
            }
        }
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
