//
//  EditViewController.swift
//  Petto
//
//  Created by admin on 2017/07/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD

class EditViewController: BaseFormViewController {
    
    var petData: PetData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    var inputData = [String : Any]()
    var inputData2 = [String : Any]() //environments
    var inputData3 = [String : Any]() //tools
    var inputData4 = [String : Any]() //ngs
    var inputData5 = [String : Any]() //userNgs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: EditViewController.viewDidLoad start")
       
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
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        // フォーム
        form +++
            Section() {
                if let _ = self.petData {
                    $0.header = HeaderFooterView<EditView>(.class)
                }else {
                    $0.header = HeaderFooterView<EntryView>(.class)
                }
            }
            <<< ImageRow("image"){
                $0.title = "写真"
                $0.baseValue = self.petData?.image ?? nil
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
            
            <<< NameRow("name") {
                $0.title = "名前"
                $0.placeholder = "ポチ"
                $0.value = self.petData?.name ?? nil
            }
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = Area.strings
                $0.value = self.petData?.area ?? $0.options.first
            }
            
            +++ Section("プロフィール")
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = Sex.strings
                $0.value = self.petData?.sex ?? nil
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
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.options = Kind.strings
                $0.value = self.petData?.kind ?? nil
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
            <<< PickerInputRow<String>("categoryDog"){
                $0.title = "品種"
                $0.hidden = .function(["kind"], { form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "kind")
                    return row.value ?? Kind.dog == Kind.cat
                })
                $0.options = CategoryDog.strings
                $0.value = self.petData?.category ?? $0.options.first
            }
            <<< PickerInputRow<String>("categoryCat"){
                $0.title = "品種"
                $0.hidden = .function(["kind"], { form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "kind")
                    return row.value ?? Kind.dog == Kind.dog
                })
                $0.options = CategoryCat.strings
                $0.value = self.petData?.category ?? $0.options.first
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.options = Age.strings
                $0.value = self.petData?.age ?? $0.options.first
            }
            
            +++ Section("状態")
            <<< CheckRow("isVaccinated") {
                $0.title = "ワクチン接種済み"
                $0.value = self.petData?.isVaccinated ?? false
            }
            <<< CheckRow("isCastrated") {
                $0.title = "去勢/避妊手術済み"
                $0.value = self.petData?.isCastrated ?? false
            }
            <<< CheckRow("wanted") {
                $0.title = "里親募集中"
                $0.value = self.petData?.wanted ?? false
            }
            <<< MultipleSelectorRow<String>("userNgs") {
                $0.title = "注意事項"
                $0.options = UserNGs.strings
                if let data = self.petData , data.userNgs.count > 0 {
                    let codes = Array(data.userNgs.keys)
                    $0.value = UserNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            
            +++ Section()
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
                $0.value = self.petData?.isAvailable ?? false
            }
            
            +++ Section("おあずけ条件"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< MultipleSelectorRow<String>("environments") {
                $0.title = "飼養環境"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                $0.options = Environment.strings
                if let data = self.petData , data.environments.count > 0 {
                    let codes = Array(data.environments.keys)
                    $0.value = Environment.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            <<< MultipleSelectorRow<String>("tools") {
                $0.title = "必要な道具"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                //TODO:アイコン表示
                $0.options = Tool.strings
                if let data = self.petData , data.tools.count > 0 {
                    let codes = Array(data.tools.keys)
                    $0.value = Tool.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "NGユーザ"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                $0.options = PetNGs.strings
                if let data = self.petData , data.ngs.count > 0 {
                    let codes = Array(data.ngs.keys)
                    $0.value = PetNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            
            +++ Section("お世話の方法"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< SegmentedRow<String>("feeding"){
                $0.title =  "ごはんの回数/日"
                $0.options = ["1回","2回","3回"]
                $0.value = self.petData?.feeding ?? nil
                
            }
            <<< SegmentedRow<String>("dentifrice") {
                $0.title = "歯磨きの回数/日"
                $0.options = ["1回","2回","3回"]
                $0.value = self.petData?.dentifrice ?? nil
            }
            <<< SegmentedRow<String>("walk") {
                $0.title = "お散歩の回数/日"
                $0.options = ["不要","1回","2回"]
                $0.value = self.petData?.walk ?? nil
            }
            +++
            Section("おあずけ可能期間"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< DateRow("startDate") {
                $0.title = "開始日付"
                if let dateString = self.petData?.startDate {
                    $0.value = DateCommon.stringToDate(dateString)
                }else{
                    $0.value = Date()
                }
                $0.minimumDate = Date()
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { [weak self] cell, row in
                //.onChange { [weak self] row in
                    let endRow: DateRow! = self?.form.rowBy(tag: "endDate")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                }/*
                .onExpandInlineRow {cell, row, inlineRow in
                    inlineRow.cellUpdate() { cell, row in
                        cell.datePicker.datePickerMode = .date
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
                }*/
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

            <<< DateRow("endDate") {
                $0.title = "終了日付"
                if let dateString = self.petData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString)
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.minimumDate = Date()
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange { [weak self] row in
                //.onRowValidationChanged { [weak self] cell, row in
                    let startRow: DateRow! = self?.form.rowBy(tag: "startDate")
                    if row.value?.compare(startRow.value!) == .orderedAscending {
                        row.cell!.backgroundColor = .red
                    }
                    else{
                        row.cell!.backgroundColor = .white
                    }
                    row.updateCell()
                }
                /*.onExpandInlineRow { cell, row, inlineRow in
                    inlineRow.cellUpdate { cell, dateRow in
                        cell.datePicker.datePickerMode = .date
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
                }*/
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
    
            +++
            Section("連続おあずけ日数"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< PickerInputRow<Int>("minDays"){
                $0.title = "最短"
                $0.options = []
                for i in 1...30{
                    $0.options.append(i)
                }
                $0.value = self.petData?.minDays ?? $0.options.first
            }
            <<< PickerInputRow<Int>("maxDays"){
                $0.title = "最長"
                $0.options = []
                for i in 1...30{
                    $0.options.append(i)
                }
                $0.value = self.petData?.maxDays ?? $0.options.last
            }
            //TODO: その他、特記事項入力フォーム
            
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "投稿する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() {
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: EditViewController.viewDidLoad \(error)")
                    }else{
                        self?.executePost()
                    }
        }
        print("DEBUG_PRINT: EditViewController.viewDidLoad end")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: EditViewController.executePost start")
        
        // HUDで処理中を表示
        SVProgressHUD.show()

        for (key,value) in form.values() {
            if value == nil {
                //break
                print("ALERT::: key値「\(key)」がnilです。")
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
                        case Environment.strings[0]: inputData2[Environment.codes[0]] = true
                        case Environment.strings[1]: inputData2[Environment.codes[1]] = true
                        case Environment.strings[2]: inputData2[Environment.codes[2]] = true
                        case Environment.strings[3]: inputData2[Environment.codes[3]] = true
                        default: break
                        }
                    }
                    inputData["environments"] = inputData2
                case "tools" :
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
                    inputData["tools"] = inputData3
                case "ngs" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case PetNGs.strings[0]: inputData4[PetNGs.codes[0]] = true
                        case PetNGs.strings[1]: inputData4[PetNGs.codes[1]] = true
                        case PetNGs.strings[2]: inputData4[PetNGs.codes[2]] = true
                        case PetNGs.strings[3]: inputData4[PetNGs.codes[3]] = true
                        case PetNGs.strings[4]: inputData4[PetNGs.codes[4]] = true
                        default: break
                        }
                    }
                    inputData["ngs"] = inputData4
                case "userNgs" :
                    for itemValue in [String] (Array(fmap)){
                        switch itemValue {
                        case UserNGs.strings[0]: inputData5[UserNGs.codes[0]] = true
                        case UserNGs.strings[1]: inputData5[UserNGs.codes[1]] = true
                        case UserNGs.strings[2]: inputData5[UserNGs.codes[2]] = true
                        case UserNGs.strings[3]: inputData5[UserNGs.codes[3]] = true
                        default: break
                        }
                    }
                    inputData["userNgs"] = inputData5
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
            ref.child(Paths.PetPath).child(data.id!).updateChildValues(inputData)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "ペット情報を更新しました")
        }else{
            let key = ref.child(Paths.PetPath).childByAutoId().key
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.PetPath).child(key).setValue(inputData)
            //ユーザのmyPetsIdを追加
            ref.child(Paths.UserPath).child(uid!).child("myPets").updateChildValues([key: true])
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "ペット情報を投稿しました")
        }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)

        // HUDを消す
        SVProgressHUD.dismiss()

        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
        print("DEBUG_PRINT: EditViewController.executePost end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class EditViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class EditView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "pet2edit"))
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

class EntryView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "pet2"))
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

