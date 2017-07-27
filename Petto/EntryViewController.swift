//
//  EntryViewController.swift
//  Petto
//
//  Created by admin on 2017/07/14.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD


class EntryViewController: FormViewController  {
    
    var inputData = [String : Any]()
    var inputData2 = [String : Any]() //environments
    var inputData3 = [String : Any]() //tools
    var inputData4 = [String : Any]() //ngs
    
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
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }

        // フォーム
        form +++
            Section() {
                $0.header = HeaderFooterView<PettoLogoView>(.class)
            }
            
            <<< ImageRow("image"){
                $0.title = "写真"
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
            }
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.options = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
                $0.value = $0.options.first
            }
            
            +++ Section("プロフィール")
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = ["♂", "♀"]
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
                $0.options = ["イヌ", "ネコ"]
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
                    return row.value ?? "イヌ" == "ネコ"
                })
                $0.options = ["雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
                $0.value = $0.options.first
            }
            <<< PickerInputRow<String>("categoryCat"){
                $0.title = "品種"
                $0.hidden = .function(["kind"], { form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "kind")
                    return row.value ?? "イヌ" == "イヌ"
                })
                $0.options = ["雑種","アビシニアン","アメリカンカール","アメリカンショートヘア","エキゾチックショートヘア","サイベリアン","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","ソマリ","ノルウェージャンフォレストキャット","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ベンガル","マンチカン","メインクーン","ラグドール","ロシアンブルー","不明"]
                $0.value = $0.options.first
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.options = ["8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
                $0.value = $0.options.first
            }
            
            +++ Section("状態")
            <<< CheckRow("isVaccinated") {
                $0.title = "ワクチン接種済み"
                $0.value = true
            }
            <<< CheckRow("isCastrated") {
                $0.title = "去勢/避妊手術済み"
                $0.value = true
            }
            <<< CheckRow("wanted") {
                $0.title = "里親募集中"
                $0.value = true
            }
            
            +++ Section()
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
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
                $0.options = ["室内のみ","エアコンあり","２部屋以上","庭あり"] //FeedingEnvironment.allValues
                $0.value = []
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
                $0.options = ["寝床","トイレ","首輪＆リード","ケージ","歯ブラシ","ブラシ","爪研ぎ","キャットタワー"]
                $0.value = []
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
                $0.options = ["Bad評価1つ以上","定時帰宅できない","一人暮らし","小児あり世帯","高齢者のみ世帯"]
                $0.value = []
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
            }
            <<< SegmentedRow<String>("dentifrice") {
                $0.title = "歯磨きの回数/日"
                $0.options = ["1回","2回","3回"]
            }
            <<< SegmentedRow<String>("walk") {
                $0.title = "お散歩の回数/日"
                $0.options = ["不要","1回","2回"]
            }
            +++
            Section("おあずけ可能期間"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< DateRow("startDate") {
                $0.value = Date()
                $0.title = "開始日付"
            }
            <<< DateRow("endDate") {
                $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                $0.title = "終了日付"
            }
            +++
            Section("連続おあずけ日数"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            //TODO: 1〜30以外はバリデーション。もしくはピッカー？
            <<< IntRow("minDays") {
                $0.title = "最短"
                $0.value = 1
            }
            <<< IntRow("maxDays") {
                $0.title = "最長"
                $0.value = 30
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "投稿する"
                }.onCellSelection { [weak self] (cell, row) in
                    print("---EntryViewController.viewDidLoad 3")
                    row.section?.form?.validate()
                    self?.executePost()
            }
        
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func executePost() {
        print("---EntryViewController.executePost")
        
        // inputDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = FIRAuth.auth()?.currentUser?.uid
        self.inputData["createAt"] = String(time)
        self.inputData["createBy"] = uid!
        
        for (key,value) in form.values() {
            if value == nil {
                break
            // String
            }else if case let itemValue as String = value {
                if key == "categoryDog" || key == "categoryCat" {
                    self.inputData["category"] = itemValue
                }else {
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
        
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        let key = ref.child(Const.PetInfoPath).childByAutoId().key

        // FireBaseに保存
        ref.child(Const.PetInfoPath).child(key).setValue(inputData)
        
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HOMEに画面遷移
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
        print("---EntryViewController.executePost ......end!")

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
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Entry") as! EntryViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }

}

class PettoLogoViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class PettoLogoView: UIView {
    
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

/*enum FeedingEnvironment : String, CustomStringConvertible {
    case Indoor_Only = "室内のみ"
    case Air_Conditioned = "エアコンあり"
    case Two_Rooms_More = "二部屋以上"
    case With_Garden = "庭あり"
    
    var description : String { return rawValue }
    
    static let allValues = [Indoor_Only, Air_Conditioned, Two_Rooms_More, With_Garden]
}
*/


