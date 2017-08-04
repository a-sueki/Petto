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

class UserViewController: FormViewController {
    
    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    var inputData = [String : Any]()
    var inputData2 = [String : Any]() //userEnvironments
    var inputData3 = [String : Any]() //userTools
    var inputData4 = [String : Any]() //userNgs
    
    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(BaseViewController.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(BaseViewController.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(BaseViewController.onClick3))
        btn4 = UIBarButtonItem(image: UIImage(named: "mail"), style: .plain, target: self, action: #selector(BaseViewController.onClick4))
        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(BaseViewController.onClick5))
        
        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns
        
        
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
        //DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        
        // フォーム
        form +++
            Section() {
                if let _ = self.userData {
                    $0.header = HeaderFooterView<UserEditView>(.class)
                }else {
                    $0.header = HeaderFooterView<UserEntryView>(.class)
                }
            }
            //TODO: コミットメント＆小さなバッチ（メダル）
            //TODO: カメラ起動追加
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
                    $0.value = dateFormatter.date(from: dateString)
                }else{
                    $0.value = dateFormatter.date(from: "1980-01-01 00:00:00 +000")
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
                $0.options = ["室内飼いOK","エアコンあり","２部屋以上","庭あり"]
                if let data = self.userData , data.userEnvironments.count > 0 {
                    let codes = Array(data.userEnvironments.keys)
                    let names:Set<String> = codeToString(key:"userEnvironments", codeList: codes)
                    $0.value = names
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
                $0.options = ["寝床","トイレ","首輪＆リード","ケージ","歯ブラシ","ブラシ","爪研ぎ","キャットタワー"]
                if let data = self.userData , data.userTools.count > 0 {
                    let codes = Array(data.userTools.keys)
                    let names:Set<String> = codeToString(key:"userTools", codeList: codes)
                    $0.value = names
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
                $0.options = ["吠え癖","噛み癖","生まれたて","持病あり"]
                if let data = self.userData , data.userNgs.count > 0 {
                    let codes = Array(data.userNgs.keys)
                    let names:Set<String> = codeToString(key:"userNgs", codeList: codes)
                    $0.value = names
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
                row.title = "投稿する"
                }.onCellSelection { [weak self] (cell, row) in
                    print("---UserViewController.viewDidLoad 3")
                    row.section?.form?.validate()
                    self?.executePost()
        }
        
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func codeToString(key: String ,codeList: [String]) -> Set<String>{
        var nameList:Set<String> = []
        switch key {
        case "userEnvironments" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("室内飼いOK")
                case "code02" : nameList.insert("エアコンあり")
                case "code03" : nameList.insert("２部屋以上")
                case "code04" : nameList.insert("庭あり")
                default: break
                }
            }
        case "userTools" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("寝床")
                case "code02" : nameList.insert("トイレ")
                case "code03" : nameList.insert("ケージ")
                case "code04" : nameList.insert("歯ブラシ")
                case "code05" : nameList.insert("ブラシ")
                case "code06" : nameList.insert("爪研ぎ")
                case "code07" : nameList.insert("キャットタワー")
                default: break
                }
            }
        case "userNgs" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("吠え癖")
                case "code02" : nameList.insert("噛み癖")
                case "code03" : nameList.insert("生まれたて")
                case "code04" : nameList.insert("持病あり")
                default: break
                }
            }
        default: break
        }
        return nameList
    }
    
    
    @IBAction func executePost() {
        print("---UserViewController.executePost  1")
        print(form.values())

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
                        case "室内飼いOK": inputData2["code01"] = true
                        case "エアコンあり": inputData2["code02"] = true
                        case "２部屋以上": inputData2["code03"] = true
                        case "庭あり": inputData2["code04"] = true
                        default: break
                        }
                    }
                    self.inputData["userEnvironments"] = inputData2
                case "userTools" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case "寝床": inputData3["code01"] = true
                        case "トイレ": inputData3["code02"] = true
                        case "ケージ": inputData3["code03"] = true
                        case "歯ブラシ": inputData3["code04"] = true
                        case "ブラシ": inputData3["code05"] = true
                        case "爪研ぎ": inputData3["code06"] = true
                        case "キャットタワー": inputData3["code07"] = true
                        default: break
                        }
                    }
                    self.inputData["userTools"] = inputData3
                case "userNgs" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case "吠え癖": inputData4["code01"] = true
                        case "噛み癖": inputData4["code02"] = true
                        case "生まれたて": inputData4["code03"] = true
                        case "持病あり": inputData4["code04"] = true
                        default: break
                        }
                    }
                    self.inputData["userNgs"] = inputData4
                default: break
                }
            }
        }
        
        print("---UserViewController.executePost  8")
        print(self.inputData)
        
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
            ref.child(Const.UserPath).child(data.id!).updateChildValues(self.inputData)
        }else{
            let key = uid//ref.child(Const.UserPath).childByAutoId().key
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Const.UserPath).child(key!).setValue(self.inputData)
        }
        
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
    
    func onClick1() {
        self.slideMenuController()?.openLeft()
    }
    func onClick2() {
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    func onClick3() {
        let viewController3 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController3, animated: true)
    }
    func onClick4() {
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        self.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
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
