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
    
    var searchData: SearchData?
    var inputData = [String : Any]()
    var removeKeyList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: SearchViewController.viewDidLoad start")

        
        print("DEBUG_PRINT: SearchViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: SearchViewController.viewWillAppear start")
        if UserDefaults.standard.string(forKey: DefaultString.WithSearch) != nil {
            self.read()
        }else{
            self.updateSearchData()
        }
        print("DEBUG_PRINT: SearchViewController.viewWillAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: SearchViewController.viewWillDisappear start")
        
        if let key = UserDefaults.standard.string(forKey: DefaultString.WithSearch) {
            let ref = Database.database().reference().child(Paths.SearchPath).child(key)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: SearchViewController.viewWillDisappear end")
    }
    
    func read() {
        print("DEBUG_PRINT: SearchViewController.read start")
        
        // Firebaseから登録済みデータを取得
        if let key = UserDefaults.standard.string(forKey: DefaultString.WithSearch) {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            let ref = Database.database().reference().child(Paths.SearchPath).child(key)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: SearchViewController.read .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    self.searchData = SearchData(snapshot: snapshot, myId: key)
                    // Formを表示
                    self.updateSearchData()
                }else{
                    self.updateSearchData()
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        }
        
        print("DEBUG_PRINT: SearchViewController.read end")
    }
    
    func updateSearchData() {
        print("DEBUG_PRINT: SearchViewController.updateSearchData start")
        
        // Cell初期設定
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        // フォーム
        form +++
            Section("絞り込み条件")
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = Area.searchStrings
                $0.value = self.searchData?.area ?? UserDefaults.standard.string(forKey: DefaultString.Area)
            }
            
            +++ Section("ペットのプロフィール①")
            <<< SwitchRow("lv1-1"){
                $0.title = "ペットのプロフで絞り込む"
                $0.value = self.searchData?.lev11 ?? false
            }
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.hidden = .function(["lv1-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv1-1")
                    return row.value ?? false == false
                })
                $0.options = Kind.searchStrings
                $0.value = self.searchData?.kind ?? $0.options?.first
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "ペットの年齢"
                $0.hidden = .function(["lv1-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv1-1")
                    return row.value ?? false == false
                })
                $0.options = Age.searchStrings
                $0.value = self.searchData?.age ?? $0.options.first
            }
            
            +++ Section("ペットのプロフィール②"){
                $0.hidden = .function(["lv1-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv1-1")
                    return row.value ?? false == false
                })
            }
            <<< SwitchRow("lv1-2"){
                $0.title = "もっと詳しく"
                $0.value = self.searchData?.lev12 ?? false
            }
            <<< SegmentedRow<String>("size") {
                $0.title =  "大きさ"
                $0.hidden = .function(["lv1-2"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv1-2")
                    return row.value ?? false == false
                })
                $0.options = Size.searchStrings
                $0.value = self.searchData?.size ?? $0.options?.first
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.hidden = .function(["lv1-2"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv1-2")
                    return row.value ?? false == false
                })
                $0.options = Sex.searchStrings
                $0.value = self.searchData?.sex ?? $0.options?.first
            }
            <<< MultipleSelectorRow<String>("color") {
                $0.title = "色"
                $0.hidden = .function(["lv1-2"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv1-2")
                    return row.value ?? false == false
                })
                $0.options = Color.strings
                if let data = self.searchData , data.color.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.color {
                        if val == true {
                            codes.append(key)
                        }
                    }
                    $0.value = Color.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            
            +++ Section("ペットあずかりに関する条件①")
            <<< SwitchRow("lv2-1"){
                $0.title = "あずかりの条件で絞り込む"
                $0.value = self.searchData?.lev21 ?? false
            }
            <<< CheckRow("isAvailable"){
                $0.title = "あずかり人を募集中"
                $0.hidden = .function(["lv2-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-1")
                    return row.value ?? false == false
                })
                $0.value = self.searchData?.isAvailable ?? true
            }
            
            +++ Section("ペットあずかりに関する条件②"){
                $0.hidden = .function(["lv2-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-1")
                    return row.value ?? false == false
                })
            }
            <<< SwitchRow("lv2-2"){
                $0.title = "もっと詳しく"
                $0.value = self.searchData?.lev22 ?? false
            }
            <<< CheckRow("toolRentalAllowed") {
                $0.title = "道具の貸し出し可能"
                $0.hidden = .function(["lv2-2"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-2")
                    return row.value ?? false == false
                })
                $0.value = self.searchData?.toolRentalAllowed ?? true
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogchain")
            }
            <<< CheckRow("feedingFeePayable") {
                $0.title = "エサ代は飼い主負担"
                $0.hidden = .function(["lv2-2"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-2")
                    return row.value ?? false == false
                })
                $0.value = self.searchData?.feedingFeePayable ?? true
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogBowl")
            }
            
            +++ Section("ペットあずかりに関する条件③"){
                $0.hidden = .function(["lv2-1","lv2-2"], { form -> Bool in
                    let row1: RowOf<Bool>! = form.rowBy(tag: "lv2-1")
                    let row2: RowOf<Bool>! = form.rowBy(tag: "lv2-2")
                    if row1.value == true && row2.value == true {
                        return false
                    }else{
                        return true
                    }
                })
            }
            <<< SwitchRow("lv2-3"){
                $0.title = "あずかり期間・日数を指定"
                $0.value = self.searchData?.lev23 ?? false
            }
            <<< DateRow("startDate") {
                $0.title = "期間（開始）"
                $0.hidden = .function(["lv2-3"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-3")
                    return row.value ?? false == false
                })
                if let dateString = self.searchData?.startDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = Date()
                }
                $0.minimumDate = Date()
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
                $0.title = "期間（終了）"
                $0.hidden = .function(["lv2-3"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-3")
                    return row.value ?? false == false
                })
                if let dateString = self.searchData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.minimumDate = Date()
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
            <<< PickerInputRow<Int>("minDays"){
                $0.title = "日数（最短）"
                $0.hidden = .function(["lv2-3"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-3")
                    return row.value ?? false == false
                })
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
                $0.title = "日数（最長）"
                $0.hidden = .function(["lv2-3"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv2-3")
                    return row.value ?? false == false
                })
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
            
            
            +++ Section("ペットの状態①")
            <<< SwitchRow("lv3-1"){
                $0.title = "ペットの状態で絞り込む"
                $0.value = self.searchData?.lev31 ?? false
            }
            <<< CheckRow("isVaccinated") {
                $0.title = "ワクチン接種済み"
                $0.hidden = .function(["lv3-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv3-1")
                    return row.value ?? false == false
                })
                $0.value = self.searchData?.isVaccinated ?? true
            }
            <<< CheckRow("isCastrated") {
                $0.title = "去勢/避妊手術済み"
                $0.hidden = .function(["lv3-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv3-1")
                    return row.value ?? false == false
                })
                $0.value = self.searchData?.isCastrated ?? true
            }
            <<< CheckRow("wanted") {
                $0.title = "里親を募集中"
                $0.hidden = .function(["lv3-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv3-1")
                    return row.value ?? false == false
                })
                $0.value = self.searchData?.wanted ?? true
            }
            
            
            +++ Section("ペットの状態②"){
                $0.hidden = .function(["lv3-1"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv3-1")
                    return row.value ?? false == false
                })
            }
            <<< SwitchRow("lv3-2"){
                $0.title = "もっと詳しく"
                $0.value = self.searchData?.lev32 ?? false
            }
            <<< MultipleSelectorRow<String>("userNgs") {
                $0.title = "訳ありペットを除外"
                $0.hidden = .function(["lv3-2"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "lv3-2")
                    return row.value ?? false == false
                })
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
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "検索条件をクリア"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.clear()
        }
        print("DEBUG_PRINT: SearchViewController.updateSearchData end")
    }
    
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clear() {
        print("DEBUG_PRINT: SearchViewController.clear start")
        
        // 辞書を作成
        let ref = Database.database().reference()
        if let key = UserDefaults.standard.string(forKey: DefaultString.WithSearch) {
            ref.child(Paths.SearchPath).child(key).removeValue()
        }
        if let uid = Auth.auth().currentUser?.uid {
            ref.child(Paths.UserPath).child(uid).child(DefaultString.WithSearch).removeValue()
            SVProgressHUD.showSuccess(withStatus: "絞り込み条件をクリアしました")
        } else{
            UserDefaults.standard.removeObject(forKey: DefaultString.WithSearch)
            SVProgressHUD.showError(withStatus: "更新に失敗しました。再度ログインしてから実行してください")
        }
        
        // ユーザーデフォルトを更新
        UserDefaults.standard.set(false , forKey: DefaultString.WithSearch)
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        
        print("DEBUG_PRINT: SearchViewController.clear end")
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: SearchViewController.executePost start")
        
        for (key,value) in form.values() {
            if value == nil {
                self.removeKeyList.append("\(key)")
                // String
            }else if case let itemValue as String = value {
                if itemValue == SearchString.unspecified {
                    self.removeKeyList.append("\(key)")
                } else {
                    self.inputData["\(key)"] = itemValue
                }
                // Bool
            }else if case let v as Bool = value {
                switch key {
                case "lv1-1": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev11)
                case "lv1-2": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev12)
                case "lv2-1": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev21)
                case "lv2-2": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev22)
                case "lv2-3": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev23)
                case "lv3-1": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev31)
                case "lv3-2": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.lev32)
                case "isVaccinated": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.isVaccinated)
                case "isCastrated": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.isCastrated)
                case "wanted": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.wanted)
                case "isAvailable": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.isAvailable)
                case "toolRentalAllowed": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.toolRentalAllowed)
                case "feedingFeePayable": self.inputData["\(key)"] = boolSet(new: v ,old: self.searchData?.feedingFeePayable)
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
                case "color" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Color.toCode(itemValue)] = true
                    }
                    self.inputData["color"] = ListSet.codeSet(codes: Color.codes, new: codeArray, old: searchData?.color)
                case "userNgs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[UserNGs.toCode(itemValue)] = true
                    }
                    self.inputData["userNgs"] = ListSet.codeSet(codes: UserNGs.codes, new: codeArray, old: self.searchData?.userNgs)
                default: break
                }
            }
        }
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = Auth.auth().currentUser?.uid
        // 辞書を作成
        let ref = Database.database().reference()
        
        //Firebaseに保存
        if let data = self.searchData {
            // 更新しないデータを引き継ぎ
            self.inputData["createAt"] = String(data.createAt!.timeIntervalSinceReferenceDate)
            self.inputData["createBy"] = data.createBy
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid ?? "guest"
            // search初期化&更新
            ref.child(Paths.SearchPath).child(data.id!).removeValue()
            ref.child(Paths.SearchPath).child(data.id!).setValue(self.inputData)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "絞り込み条件を更新しました")
        }else{
            let key = ref.child(Paths.SearchPath).childByAutoId().key
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid ?? "guest"
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid ?? "guest"
            // insert
            ref.child(Paths.SearchPath).child(key).setValue(inputData)
            //ユーザのwithSearchを追加
            if uid != nil{
                ref.child(Paths.UserPath).child(uid!).updateChildValues(["withSearch": key])
            }
            // ユーザーデフォルトを更新
            UserDefaults.standard.set(key , forKey: DefaultString.WithSearch)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "絞り込み条件を保存しました")
        }
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
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
    
}
class SearchView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "pet2search"))
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
