//
//  SearchViewController.swift
//  Petto
//
//  Created by admin on 2017/08/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD

class SearchViewController: BaseFormViewController {
    
    let userDefaults = UserDefaults.standard
    var searchData: SearchData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        print("DEBUG_PRINT: SearchViewController.viewDidLoad start")
        super.viewDidLoad()
        
        // Firebaseから登録済みデータを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.SearchPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: SearchViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    
                    self.searchData = SearchData(snapshot: snapshot, myId: uid)

                    // Formを表示
                    self.updateSearchData()
                }else{
                    // Formを表示
                    self.updateSearchData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            observing = true
        }else{
            self.updateSearchData()
        }
        print("DEBUG_PRINT: SearchViewController.viewDidLoad end")
    }

    func updateSearchData() {
        print("DEBUG_PRINT: SearchViewController.updateSearchData start")
    
        // Cell初期設定
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        // フォーム
        //TODO: 「指定しない」を選択できるようにする
        form +++
            Section("絞り込み条件") {
                $0.header = HeaderFooterView<SearchView>(.class)
            }
            +++ Section("ペットのプロフィール")
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = Area.strings
                $0.value = self.searchData?.area ?? userDefaults.string(forKey: DefaultString.Area)
            }
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.options = Kind.strings
                $0.value = self.searchData?.kind ?? nil
            }
            //TODO: もうちょい選択しやすいUIに変更
            <<< PickerInputRow<String>("categoryDog"){
                $0.title = "品種"
                $0.hidden = .function(["kind"], { form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "kind")
                    return row.value ?? Kind.dog == Kind.cat
                })
                $0.options = CategoryDog.strings
                $0.value = self.searchData?.category ?? $0.options.last
            }
            <<< PickerInputRow<String>("categoryCat"){
                $0.title = "品種"
                $0.hidden = .function(["kind"], { form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "kind")
                    return row.value ?? Kind.dog == Kind.dog
                })
                $0.options = CategoryCat.strings
                $0.value = self.searchData?.category ?? $0.options.last
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.options = Age.strings
                $0.value = self.searchData?.age ?? $0.options.last
            }
            
            +++ Section("ペットの状態")
            //TODO: チェックボックスを表示
            <<< CheckRow("isVaccinated") {
                $0.title = "ワクチン接種済み"
                $0.value = self.searchData?.isVaccinated ?? false
            }
            <<< CheckRow("isCastrated") {
                $0.title = "去勢/避妊手術済み"
                $0.value = self.searchData?.isCastrated ?? false
            }
            <<< CheckRow("wanted") {
                $0.title = "里親を募集中"
                $0.value = self.searchData?.wanted ?? false
            }

            +++ Section("おあずけ条件")
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集中"
                $0.value = self.searchData?.isAvailable ?? true
            }
            <<< MultipleSelectorRow<String>("environments") {
                $0.title = "飼養環境"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                $0.options = Environment.strings
                if let data = self.searchData , data.environments.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.environments {
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
            //TODO: 道具の貸し出しがアリかナシかだけ選択
            <<< MultipleSelectorRow<String>("tools") {
                $0.title = "必要な道具"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                $0.options = Tool.strings
                if let data = self.searchData , data.tools.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.tools {
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
                $0.title = "除外するペット"
                $0.options = UserNGs.strings
                if let data = self.searchData , data.userNgs.count > 0 {
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


            +++
            Section("おあずけ可能期間"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< DateRow("startDate") {
                $0.title = "開始日付"
                if let dateString = self.searchData?.startDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = Date()
                }
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange { [weak self] row in
                    let endRow: DateRow! = self?.form.rowBy(tag: "endDate")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                }
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
                if let dateString = self.searchData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.cell.datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<Date>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleClosure { [weak self] row -> ValidationError? in
                    let startRow: DateRow! = self!.form.rowBy(tag: "startDate")
                    let endRow: DateRow! = self!.form.rowBy(tag: "endDate")
                    if startRow.value?.compare(endRow.value!) == .orderedDescending {
                        return ValidationError(msg: ErrorMsgString.RuleEndDate)
                    }
                    return nil
                })
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChange
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
                $0.value = self.searchData?.minDays ?? $0.options.first
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange { [weak self] row in
                    let maxRow: PickerInputRow<Int>! = self?.form.rowBy(tag: "maxDays")
                    if let min = row.value, let max = maxRow?.value, min > max {
                        maxRow.value = row.value! + 1
                        maxRow.cell!.backgroundColor = .white
                        maxRow.updateCell()
                    }
                }
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
            <<< PickerInputRow<Int>("maxDays"){
                $0.title = "最長"
                $0.options = []
                for i in 1...30{
                    $0.options.append(i)
                }
                $0.value = self.searchData?.maxDays ?? $0.options.last
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<Int>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleClosure { [weak self] row -> ValidationError? in
                    let minRow: PickerInputRow<Int>! = self!.form.rowBy(tag: "minDays")
                    let maxRow: PickerInputRow<Int>! = self!.form.rowBy(tag: "maxDays")
                    if let min = minRow?.value, let max = maxRow?.value, min > max {
                        return ValidationError(msg: ErrorMsgString.RuleMaxDate)
                    }
                    return nil
                })
                
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChange
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
            //TODO: 並び順
            
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "この条件で絞り込む"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate() , error.count != 0{
                        SVProgressHUD.showError(withStatus: "入力を修正してください")
                        print("DEBUG_PRINT: UserViewController.updateUserData \(error)のため処理は行いません")
                    }else{
                        self?.executePost()
                    }
        }
        print("DEBUG_PRINT: SearchViewController.updateSearchData end")
    }

    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    
    @IBAction func executePost() {
        print("DEBUG_PRINT: SearchViewController.executePost start")
        
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
            }else if case let v as Bool = value {
                switch key {
                case "isVaccinated": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.isVaccinated)
                case "isCastrated": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.isCastrated)
                case "wanted": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.wanted)
                case "isAvailable": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.isAvailable)
                default: break
                }
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
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Environment.toCode(itemValue)] = true
                    }
                    self.inputData["environments"] = codeSet(codes: Environment.codes, new: codeArray, old: searchData?.environments)
                case "tools" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Tool.toCode(itemValue)] = true
                    }
                    self.inputData["tools"] = codeSet(codes: Tool.codes, new: codeArray, old: searchData?.tools)
                case "ngs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[UserNGs.toCode(itemValue)] = true
                    }
                    self.inputData["ngs"] = codeSet(codes: UserNGs.codes, new: codeArray, old: self.searchData?.ngs)
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
        if let data = self.searchData {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // update
            ref.child(Paths.SearchPath).child(data.id!).updateChildValues(inputData)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "絞り込み条件を更新しました")
        }else{
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.SearchPath).child(uid!).setValue(inputData)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "絞り込み条件を保存しました")
         }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HUDを消す
        SVProgressHUD.dismiss()

        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        //viewController2.searchData = inputData
        self.navigationController?.pushViewController(viewController2, animated: true)

        print("DEBUG_PRINT: SearchViewController.executePost end")
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
class SearchView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "search"))
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
