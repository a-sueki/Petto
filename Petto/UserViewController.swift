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
import PostalAddressRow

class UserViewController: FormViewController {
    var addressString: String?
    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
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
        //DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
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
            //TODO:入力中に赤字になる
            <<< ZipCodeRow("zipCode") {
                $0.title = "郵便番号"
                $0.placeholder = "1234567"
                $0.add(rule: RuleMinLength(minLength: 7))
                $0.add(rule: RuleMaxLength(maxLength: 7))
                $0.validationOptions = .validatesOnChange
/*                }.onCellHighlightChanged {cell,row in
                    if row.value != nil {
                        self.getAdressString(zipCode: row.value!)
                    }
*/                }.cellUpdate { cell, row in
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
            /*            <<< ButtonRow("search") { (row: ButtonRow) -> Void in
             row.title = "住所検索"
             }.onCellSelection { [weak self] (cell, row) in
             print("---住所検索中---")
             if let code: RowOf<String> = self!.form.rowBy(tag: "zipCode"){
             print("---住所検索中2---")
             self?.getAdressString(zipCode: code.value!)
             self!.form.rowBy(tag: "address")?.baseValue = self?.userData?.address ?? "不明！！"
             }
             }
             */

            //TODO:スイッチじゃなくボタンにする
            +++ Section()
            <<< SwitchRow("searchAddress"){
                $0.title = "郵便番号で住所検索"
                }.onChange{ row in
                    if let code: RowOf<String> = self.form.rowBy(tag: "zipCode"){
                    print("---住所検索中っっっっ---")
                    let aa = self.getAdressString(zipCode: code.value!)
                    self.form.rowBy(tag: "address")?.baseValue = aa
                    }
                //$0.value = self.petData?.isAvailable ?? false
                }
            
            +++
            Section("じゅうしょ")

            //TODO:ZIPCODE入力で自動補完
            <<< NameRow("address") {
                $0.title = "住所"
                $0.hidden = .function(["searchAddress"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "searchAddress")
                    return row.value ?? false == false
                })
                $0.value = self.userData?.address ?? nil
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    print("---住所検索中---")
                    if let code: RowOf<String> = self.form.rowBy(tag: "zipCode"){
                        print("---住所検索中2---")
                        let jj = self.getAdressString(zipCode: code.value!)
                        self.form.rowBy(tag: "address")?.baseValue = jj 
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
            //TODO:エリア（表示のみ。Disable）
            //TODO:TEL
            //TODO:現在、他にペットを飼っている
            //TODO:過去、ペット飼育経験がある

            //TODO:飼養環境
            //TODO:用意できる道具
            //TODO:NGペット（吠える、生後8ヶ月未満の子犬、噛み癖、毛が抜ける）
            //TODO:Petto利用履歴
            

            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "投稿する"
                }.onCellSelection { [weak self] (cell, row) in
                    print("---EntryViewController.viewDidLoad 3")
                    row.section?.form?.validate()
                    self?.executePost()
        }
        
    }

    func getAdressString(zipCode: String) -> String {
        var kk :String = "karappo"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error ?? "unknown...")
            }
            if let placemark = placemarks?.first {
                print("State:       \(placemark.administrativeArea!)")
                print("City:        \(placemark.locality!)")
                print("SubLocality: \(placemark.subLocality!)")
                self.addressString = placemark.administrativeArea!
                //kk = placemark.administrativeArea!
            }
        })
        return self.addressString ?? kk
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func codeToString(key: String ,codeList: [String]) -> Set<String>{
        var nameList:Set<String> = []
        switch key {
        case "environments" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("室内のみ")
                case "code02" : nameList.insert("エアコンあり")
                case "code03" : nameList.insert("２部屋以上")
                case "code04" : nameList.insert("庭あり")
                default: break
                }
            }
        case "tools" :
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
        case "ngs" :
            for code in codeList {
                switch code {
                case "code01" : nameList.insert("Bad評価1つ以上")
                case "code02" : nameList.insert("定時帰宅できない")
                case "code03" : nameList.insert("一人暮らし")
                case "code04" : nameList.insert("小児あり世帯")
                case "code05" : nameList.insert("高齢者のみ世帯")
                default: break
                }
            }
        default: break
        }
        return nameList
    }
    
    
    @IBAction func executePost() {
        print("---EntryViewController.executePost")
        
/*        for (key,value) in form.values() {
            if value == nil {
                break
                // String
            }else if case let itemValue as String = value {
                if key == "categoryDog" || key == "categoryCat" {
                    self.inputData["category"] = itemValue
                }else{
                    self.inputData["\(key)"] = itemValue
                }
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
                case "environments" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case "室内のみ": inputData2["code01"] = true
                        case "エアコンあり": inputData2["code02"] = true
                        case "２部屋以上": inputData2["code03"] = true
                        case "庭あり": inputData2["code04"] = true
                        default: break
                        }
                    }
                    inputData["environments"] = inputData2
                case "tools" :
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
                    inputData["tools"] = inputData3
                case "ngs" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case "Bad評価1つ以上": inputData4["code01"] = true
                        case "定時帰宅できない": inputData4["code02"] = true
                        case "一人暮らし": inputData4["code03"] = true
                        case "小児あり世帯": inputData4["code04"] = true
                        case "高齢者のみ世帯": inputData4["code05"] = true
                        default: break
                        }
                    }
                    inputData["ngs"] = inputData4
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
        if let data = self.petData {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // update
            ref.child(Const.PetPath).child(data.id!).updateChildValues(inputData)
        }else{
            let key = ref.child(Const.PetPath).childByAutoId().key
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Const.PetPath).child(key).setValue(inputData)
        }
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
*/
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
    
    //    @IBOutlet weak var imageView: UIImageView!
    
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
