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
    
    var petInfoData = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            // TODO: Firebase連携
            +++ Section("requirement")
            <<< SwitchRow("あずかり人を募集する"){
                $0.title = $0.tag
            }
            <<< ButtonRow("おあずけ条件設定") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "ListSectionsControllerSegue", onDismiss: nil)
            }
            
            <<< MultipleSelectorRow<String>() {
                $0.title = "環境条件"
                $0.options = ["室内のみ", "エアコンあり", "専有面積30㎡以上","2部屋以上"]
                $0.value = []
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
                }.onChange{row in
                    let mySet = row.value
                    print("+++++\(Array(mySet!))++++++")
                    //TODO: environmentsにpetIDを紐づけて登録する
                    self.petInfoData["environments"] = String(describing: row.value)
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
        
        // petInfoDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        // 辞書を作成してFirebaseに保存する
        let postRef = FIRDatabase.database().reference().child(Const.PetInfoPath)
        self.petInfoData["createAt"] = String(time)
        self.petInfoData["createBy"] = uid!
        
        print(form.values())
        for item in form.values() {
            if let itemValue = item.value {
                if item.key == "image" {
                    let imageData = UIImageJPEGRepresentation(item.value! as! UIImage, 0.5)
                    let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
                    self.petInfoData["imageString"] = imageString
                }else{
                    self.petInfoData["\(item.key)"] = String(describing: itemValue)
                }
            }
        }
        print(self.petInfoData)
        postRef.childByAutoId().setValue(petInfoData)
        
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





/*
 
 // MARK: ListSectionsController
 class ListSectionsController: FormViewController {
 var postData = [String : String]()
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 let environments = ["室内のみ", "エアコンあり", "専有面積30㎡以上","2部屋以上"]
 form +++ SelectableSection<ImageCheckRow<String>>("飼養環境", selectionType: .multipleSelection)
 for option in environments {
 form.last! <<< ImageCheckRow<String>(option){ lrow in
 lrow.title = option
 lrow.selectableValue = option
 lrow.value = nil
 }.cellSetup { cell, _ in
 cell.trueImage = UIImage(named: "checked-yellow")!
 cell.falseImage = UIImage(named: "unchecked")!
 cell.accessoryType = .checkmark
 }
 
 }
 
 let tools = ["ペット用ベッド", "ペット用トイレ", "首輪＆リード", "ケージ（柵）" , "キャットタワー", "爪とぎ"]
 form +++ SelectableSection<ImageCheckRow<String>>("必要な道具", selectionType: .multipleSelection)
 for option in tools {
 form.last! <<< ImageCheckRow<String>(option){ lrow in
 lrow.title = option
 lrow.selectableValue = option
 lrow.value = nil
 }.cellSetup { cell, _ in
 cell.trueImage = UIImage(named: "checked-yellow")!
 cell.falseImage = UIImage(named: "unchecked")!
 cell.accessoryType = .checkmark
 }
 }
 
 let ngs = ["Bad評価1以上", "定時帰宅できない", "一人暮らし", "小児と同居" , "高齢者と同居"]
 form +++ SelectableSection<ImageCheckRow<String>>("あずかり人NG条件", selectionType: .multipleSelection)
 for option in ngs {
 form.last! <<< ImageCheckRow<String>(option){ lrow in
 lrow.title = option
 lrow.selectableValue = option
 lrow.value = nil
 }.cellSetup { cell, _ in
 cell.trueImage = UIImage(named: "checked-yellow")!
 cell.falseImage = UIImage(named: "unchecked")!
 cell.accessoryType = .checkmark
 }
 }
 
 DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
 
 // TODO: Firebase連携
 form
 +++
 Section("お世話の方法")
 <<< SegmentedRow<String>() {
 $0.title =  "ごはんの回数/日"
 $0.options = ["1回","2回","3回"]
 }
 <<< SegmentedRow<String>() {
 $0.title = "歯磨きの回数/日"
 $0.options = ["1回","2回","3回"]
 }
 <<< SegmentedRow<String>() {
 $0.title = "お散歩の回数/日"
 $0.options = ["不要","1回","2回"]
 }
 
 +++
 Section("おあずけ可能期間")
 <<< DateRow() {
 $0.value = Date()
 $0.title = "開始日付"
 }
 <<< DateRow() {
 $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
 $0.title = "終了日付"
 }
 
 +++
 Section("連続おあずけ日数")
 <<< IntRow() {
 $0.title = "最短"
 $0.value = 1
 }
 <<< IntRow() {
 $0.title = "最長"
 $0.value = 30
 }
 
 print("---ListSectionsController.viewDidLoad--end")
 print(form.values())
 
 }
 // 選択が変更された時の処理
 //   ２回呼ばれる。
 //     １回目：　oldValue = some  ,  newValue = nil
 //     2回目：　oldValue = nil   ,  newValue = some
 override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
 print("---ListSectionsController.valueHasBeenChanged--start")
 row.updateCell()
 
 //TODO: フォームごとの処理切り替え
 if row.section === form[0]{
 let selectedList = (row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue})
 for selectedRow in selectedList {
 if let rowname = selectedRow {
 self.postData["\(rowname)"] = "true"
 }
 }
 }else if row.section === form[1]{
 let selectedList = (row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue})
 for selectedRow in selectedList {
 if let rowname = selectedRow {
 self.postData["\(rowname)"] = "true"
 }
 }
 }else if row.section === form[2]{
 let selectedList = (row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue})
 for selectedRow in selectedList {
 if let rowname = selectedRow {
 self.postData["\(rowname)"] = "true"
 }
 }
 }
 print(self.postData)
 print("---ListSectionsController.valueHasBeenChanged--end")
 
 
 }
 
 }
 */
