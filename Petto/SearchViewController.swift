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
    var inputData2 = [String : Any]() //environments
    var inputData3 = [String : Any]() //tools
    var inputData4 = [String : Any]() //ngs
    var inputData5 = [String : Any]() //userNgs
    
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
            +++ Section("ほほほ")
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
            
            +++ Section("状態")
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

            +++ Section("条件")
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
                    let codes = Array(data.environments.keys)
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
                //TODO:アイコン表示
                $0.options = Tool.strings
                if let data = self.searchData , data.tools.count > 0 {
                    let codes = Array(data.tools.keys)
                    $0.value = Tool.convertList(codes)
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
                if let dateString = self.searchData?.startDate {
                    $0.value = DateCommon.stringToDate(dateString)
                }else{
                    $0.value = Date()
                }
                $0.title = "開始日付"
            }
            //TODO: 開始日付以降のチェック
            <<< DateRow("endDate") {
                if let dateString = self.searchData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString)
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.title = "終了日付"
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
            }
            <<< PickerInputRow<Int>("maxDays"){
                $0.title = "最長"
                $0.options = []
                for i in 1...30{
                    $0.options.append(i)
                }
                $0.value = self.searchData?.maxDays ?? $0.options.last
            }
            //TODO: 並び順
            
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "この条件で絞り込む"
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.executePost()
        }
        print("DEBUG_PRINT: SearchViewController.updateSearchData end")
    }

    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        print("DEBUG_PRINT: SearchViewController.updateSearchData 7")
    }

    
    @IBAction func executePost() {
        print("DEBUG_PRINT: SearchViewController.executePost start")
        
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
        if let data = self.searchData {
            self.inputData["updateAt"] = String(time)
            self.inputData["updateBy"] = uid!
            // update
            ref.child(Paths.SearchPath).child(data.id!).updateChildValues(inputData)
        }else{
            self.inputData["createAt"] = String(time)
            self.inputData["createBy"] = uid!
            // insert
            ref.child(Paths.SearchPath).child(uid!).setValue(inputData)
         }
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "絞り込み条件を保存しました。")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
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
