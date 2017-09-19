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
import FirebaseStorageUI
import SVProgressHUD
import Toucan

class EditViewController: BaseFormViewController {
    
    var petData: PetData?
    var inputData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: EditViewController.viewDidLoad start")
        
        let view = UIImageView()
        if let key = self.petData?.id {
            view.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
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
            <<< NameRow("name") {
                $0.title = "名前"
                $0.placeholder = "ポチ"
                $0.value = self.petData?.name ?? nil
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnBlur
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogtag")
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
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = Area.strings
                $0.value = self.petData?.area ?? UserDefaults.standard.string(forKey: DefaultString.Area)
                $0.add(rule: RuleRequired())
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    return (rowValue == nil || rowValue!.isEmpty || rowValue == SelectString.unspecified) ? ValidationError(msg: "エリアを選択してください") : nil
                }
                $0.add(rule: ruleRequiredViaClosure)
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "maker")
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
            //TODO: 犬猫以外も選べるようにする
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.options = Kind.strings
                $0.value = self.petData?.kind ?? $0.options.first
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
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = Sex.strings
                $0.value = self.petData?.sex ?? $0.options.first
            }
            
            
            +++ Section()
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
                $0.value = self.petData?.isAvailable ?? false
            }
            
            +++
            Section(header: "あずかり人の募集条件", footer: "期間外では、自動的に募集OFFになります"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< CheckRow("toolRentalAllowed") {
                $0.title = "道具の貸し出し可能"
                $0.value = self.petData?.toolRentalAllowed ?? true
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogchain")
            }
            <<< CheckRow("feedingFeePayable") {
                $0.title = "エサ代は飼い主負担"
                $0.value = self.petData?.feedingFeePayable ?? true
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogBowl")
            }
            <<< DateRow("startDate") {
                $0.title = "開始日付"
                if let dateString = self.petData?.startDate {
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
                $0.title = "終了日付"
                if let dateString = self.petData?.endDate {
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
            
            +++
            Section(header:"連続おあずけ日数", footer:"連続30日間以上でのおあずけ依頼はできません。"){
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
                $0.value = self.petData?.maxDays ?? $0.options.last
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
            
            +++ Section()
            <<< SwitchRow("enterDetails"){
                $0.title = "もっと詳しく入力する"
                $0.value = self.petData?.enterDetails ?? false
            }
            
            +++ Section("プロフィール（任意）"){
                $0.hidden = .function(["enterDetails"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    return row.value ?? false == false
                })
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.options = Age.strings
                $0.value = self.petData?.age ?? $0.options.first
            }
            <<< SegmentedRow<String>("size") {
                $0.title =  "大きさ"
                $0.options = Size.strings
                $0.value = self.petData?.size ?? $0.options.first
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< MultipleSelectorRow<String>("color") {
                $0.title = "色"
                $0.options = Color.strings
                if let data = self.petData , data.color.count > 0 {
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
            //TODO:もっと選びやすいUIにする
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
            
            
            +++ Section("ペットの状態"){
                $0.hidden = .function(["enterDetails"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    return row.value ?? false == false
                })
            }
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
                $0.title = "あずかり人への留意事項"
                $0.options = UserNGs.strings
                if let data = self.petData , data.userNgs.count > 0 {
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
            
            
            
            +++ Section(header: "おあずけ条件(任意)", footer: "おあずけの際、あずかり人に確認してもらいましょう"){
                $0.hidden = .function(["isAvailable","enterDetails"], { form -> Bool in
                    let row1: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    let row2: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    if row1.value == true && row2.value == true {
                        return false
                    }
                    return true
                })
            }
            <<< MultipleSelectorRow<String>("environments") {
                $0.title = "飼養環境"
                $0.options = Environment.strings
                if let data = self.petData , data.environments.count > 0 {
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
            
            <<< MultipleSelectorRow<String>("tools") {
                $0.title = "必要な道具"
                $0.options = Tool.strings
                if let data = self.petData , data.tools.count > 0 {
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
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "おあずけNGユーザ"
                $0.options = PetNGs.strings
                if let data = self.petData , data.ngs.count > 0 {
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
            <<< SegmentedRow<String>("feeding"){
                $0.title =  "ごはんの回数/日"
                $0.options = ["1回","2回","3回","その他"]
                $0.value = self.petData?.feeding ?? $0.options.last
                
            }
            <<< SegmentedRow<String>("dentifrice") {
                $0.title = "歯磨きの回数/日"
                $0.options = ["1回","2回","3回","その他"]
                $0.value = self.petData?.dentifrice ?? $0.options.last
            }
            <<< SegmentedRow<String>("walk") {
                $0.title = "お散歩の回数/日"
                $0.options = ["不要","1回","2回","その他"]
                $0.value = self.petData?.walk ?? $0.options.last
            }
            
            +++
            Section("その他、特記事項など（任意）"){
                $0.hidden = .function(["enterDetails"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    return row.value ?? false == false
                })
            }
            <<< TextAreaRow("notices") {
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                $0.value = self.petData?.notices ?? nil
           }
            
            
            
            +++ Section(footer: "※投稿したペットは削除できません（編集・非活性は可）")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "投稿する"
                }.onCellSelection { [weak self] (cell, row) in
                    if let error = row.section?.form?.validate(), error.count != 0 {
                        SVProgressHUD.showError(withStatus: "\(error.count)件の入力エラーがあります")
                        print("DEBUG_PRINT: EditViewController.viewDidLoad \(error)")
                    }else{
                        self?.executePost()
                    }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "思い出フォト・コメントを見る"
                row.hidden = .function([""], { form -> Bool in
                    if self.petData != nil, self.petData?.historys != nil, !(self.petData?.historys.isEmpty)! {
                        return false
                    }else{
                        return true
                    }
                })
                }.onCellSelection { [weak self] (cell, row) in
                    self?.toHistory()
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "もどる"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.back()
        }

        print("DEBUG_PRINT: EditViewController.viewDidLoad end")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func executePost() {
        print("DEBUG_PRINT: EditViewController.executePost start")
        
        var photeImage: UIImage?
        
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
                photeImage = Toucan(image: itemValue).resize(CGSize(width: 200, height: 200), fitMode: Toucan.Resize.FitMode.clip).image
                // Bool
            }else if case let v as Bool = value {
                switch key {
                case "isVaccinated": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.isVaccinated)
                case "isCastrated": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.isCastrated)
                case "wanted": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.wanted)
                case "isAvailable": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.isAvailable)
                case "enterDetails": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.enterDetails)
                case "toolRentalAllowed": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.toolRentalAllowed)
                case "feedingFeePayable": self.inputData["\(key)"] = boolSet(new: v ,old: self.petData?.feedingFeePayable)
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
                    self.inputData["color"] = ListSet.codeSet(codes: Color.codes, new: codeArray, old: petData?.color)
                case "environments" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Environment.toCode(itemValue)] = true
                    }
                    self.inputData["environments"] = ListSet.codeSet(codes: Environment.codes, new: codeArray, old: petData?.environments)
                case "tools" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[Tool.toCode(itemValue)] = true
                    }
                    self.inputData["tools"] = ListSet.codeSet(codes: Tool.codes, new: codeArray, old: petData?.tools)
                case "ngs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[PetNGs.toCode(itemValue)] = true
                    }
                    self.inputData["ngs"] = ListSet.codeSet(codes: PetNGs.codes, new: codeArray, old: self.petData?.ngs)
                case "userNgs" :
                    var codeArray = [String : Bool]()
                    for itemValue in [String] (Array(fmap)){
                        codeArray[UserNGs.toCode(itemValue)] = true
                    }
                    self.inputData["userNgs"] = ListSet.codeSet(codes: UserNGs.codes, new: codeArray, old: petData?.userNgs)
                default: break
                }
            }
        }
        
        // HUDで処理中を表示
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = UserDefaults.standard.string(forKey: DefaultString.Uid)
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        
        //Firebaseに保存
        if let data = self.petData {
            // 更新しないデータを引き継ぎ
            self.inputData["createAt"] = String(data.createAt!.timeIntervalSinceReferenceDate)
            self.inputData["createBy"] = data.createBy
            self.inputData["roomIds"] = data.roomIds
            self.inputData["historys"] = data.historys
            self.inputData["runningFlag"] = data.runningFlag
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // pet初期化&更新
            ref.child(Paths.PetPath).child(data.id!).removeValue()
            ref.child(Paths.PetPath).child(data.id!).setValue(self.inputData)
            storageUpload(photeImage: photeImage!, key: data.id!)

            // room更新
            var roomUpdateData1 = [String : Any]()
            for (roomId,_) in data.roomIds {
                roomUpdateData1["\(Paths.RoomPath)/\(roomId)/petName"] = self.inputData["name"]
                roomUpdateData1["\(Paths.RoomPath)/\(roomId)/updateAt"] = self.inputData["updateAt"]
            }
            if !roomUpdateData1.isEmpty{
                ref.updateChildValues(roomUpdateData1)
            }
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "ペット情報を更新しました")
        }else{
            let key = ref.child(Paths.PetPath).childByAutoId().key
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            
            // insert
            ref.child(Paths.PetPath).child(key).setValue(self.inputData)
            storageUpload(photeImage: photeImage!, key: key)
            
            //ユーザのmyPetsIdを追加
            ref.child(Paths.UserPath).child(uid!).child("myPets").updateChildValues([key: true])
            // ユーザーデフォルトを更新
            if UserDefaults.standard.dictionary(forKey: DefaultString.MyPets) != nil && !UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)!.isEmpty {
                var myPets = UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)!
                myPets[key] = true
                UserDefaults.standard.set(myPets , forKey: DefaultString.MyPets)
            }else{
                var myPets = [String:Bool]()
                myPets[key] = true
                UserDefaults.standard.set(myPets , forKey: DefaultString.MyPets)
            }
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
    
    @IBAction func back() {
        print("DEBUG_PRINT: EditViewController.back start")
        
        //前画面に戻る
        self.navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: EditViewController.back end")
    }
    
    @IBAction func toHistory() {
        print("DEBUG_PRINT: EditViewController.toHistory start")
        
        // historyに画面遷移
        let historyViewController = self.storyboard?.instantiateViewController(withIdentifier: "History") as! HistoryViewController
        historyViewController.petData = self.petData
        self.navigationController?.pushViewController(historyViewController, animated: true)
        
        print("DEBUG_PRINT: EditViewController.toHistory end")
    }

    
    func storageUpload(photeImage: UIImage, key: String){
        
        if let data = UIImageJPEGRepresentation(photeImage, 0.25) {
            StorageRef.getRiversRef(key: key).put(data , metadata: nil) { (metadata, error) in
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
