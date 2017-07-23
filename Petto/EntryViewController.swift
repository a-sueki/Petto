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
    
    var inputData1 = [String : Any]()
    var inputData2 = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: NavigationBar表示
        
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
        
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }
        
        form +++
            Section() {
                var header = HeaderFooterView<PettoLogoViewNib>(.nibFile(name: "EntrySectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 1;
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                }
                $0.header = header
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
            
            +++ Section("Profile")
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
            <<< PickerInputRow<String>("category"){
                $0.title = "品種"
                $0.options = ["雑種","キャバリア","コーギー","ゴールデン・レトリバー","シー・ズー","柴犬","ダックスフンド","チワワ","パグ","パピヨン","ビーグル","ピンシャー","プードル/トイ・プードル","ブルドッグ","フレンチ・ブルドッグ","ボーダー・コリー","ポメラニアン","マルチーズ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ヨークシャ・テリア","ラブラドール・レトリバー","不明"]
                $0.value = $0.options.first
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.options = ["8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]
                $0.value = $0.options.first
            }
            
            +++ Section("Condition")
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
            
            // TODO: UI作成
            +++ Section("requirement")
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
            }
            // TODO: コード化。ベタにしないでもっとスマートにできないか？
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
        
        // inputData1に必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = FIRAuth.auth()?.currentUser?.uid
        self.inputData1["createAt"] = String(time)
        self.inputData1["createBy"] = uid!
        
        for (key,value) in form.values() {
            // String
            if value == nil {
                break
            }else if case let itemValue as String = value {
                self.inputData1["\(key)"] = String(describing: itemValue)
            // UIImage
            }else if case let itemValue as UIImage = value {
                let imageData = UIImageJPEGRepresentation(itemValue , 0.5)
                let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
                self.inputData1["imageString"] = imageString
            // Bool
            }else if case _ as Bool = value {
                self.inputData1["\(key)"] = true
            // List
            // TODO : コード化。もっとスマートにできないか。
            }else {
                let fmap = (value as! Set<String>).flatMap({$0.components(separatedBy: ",")})
                for itemValue in [String] (Array(fmap)){
                    switch itemValue {
                    case "室内のみ": inputData2["env01"] = true
                    case "エアコンあり": inputData2["env02"] = true
                    case "２部屋以上": inputData2["env03"] = true
                    case "庭あり": inputData2["env04"] = true
                    default: break
                    }
                }
                inputData1["environments"] = inputData2
            }
        }
        
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        let key = ref.child(Const.PetInfoPath).childByAutoId().key

        // FireBaseに保存
        ref.child(Const.PetInfoPath).child(key).setValue(inputData1)
//        ref.child(Const.PetInfoPath).child(key).child("environments").setValue(inputData2)
        
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let imageView = UIImageView(image: UIImage(named: "catFootptint_orenge"))
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// TODO: コード化
/*enum FeedingEnvironment : String, CustomStringConvertible {
    case Indoor_Only = "室内のみ"
    case Air_Conditioned = "エアコンあり"
    case Two_Rooms_More = "二部屋以上"
    case With_Garden = "庭あり"
    
    var description : String { return rawValue }
    
    static let allValues = [Indoor_Only, Air_Conditioned, Two_Rooms_More, With_Garden]
}
*/


