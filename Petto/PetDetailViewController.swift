//
//  PetDetailViewController.swift
//  Petto
//
//  Created by admin on 2017/08/14.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD


class PetDetailViewController: BaseFormViewController {
    
    var petData: PetData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: PetDetailViewController.viewDidLoad start")
        
        // フォーム
        form +++
            Section() {
                if let _ = self.petData {
                    var header = HeaderFooterView<PetDetailViewNib>(.nibFile(name: "PetDetailHeader", bundle: nil))
                    header.onSetupView = { (view, section) -> () in
                        view.petImageView.image = self.petData!.image
                        
                        view.petImageView.alpha = 1;
/*                        UIView.animate(withDuration: 2.0, animations: { [weak view] in
                            view?.petImageView.alpha = 1
                        })
                        view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view] in
                            view?.layer.transform = CATransform3DIdentity
                        })
 */
                    }
                    $0.header = header
                }
            }
            <<< NameRow("name") {
                $0.title = "名前"
                $0.value = self.petData?.name ?? nil
                $0.disabled = true
            }
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.value = self.petData?.area ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.options = Kind.strings
                $0.value = self.petData?.kind ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = Sex.strings
                $0.value = self.petData?.sex ?? nil
                $0.disabled = true
            }
            
            +++ Section()
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
                $0.value = self.petData?.isAvailable ?? false
                $0.disabled = true
            }

            +++
            Section(header: "おあずけ人募集期間", footer: "期間外では、自動的にあずかり人募集表示がOFFになります"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< CheckRow("toolRentalAllowed") {
                $0.title = "道具の貸し出し可能"
                $0.value = self.petData?.toolRentalAllowed ?? true
                $0.disabled = true
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogchain")
            }
            <<< CheckRow("feedingFeePayable") {
                $0.title = "エサ代は飼い主負担"
                $0.value = self.petData?.feedingFeePayable ?? true
                $0.disabled = true
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "dogBowl")
            }
            <<< DateRow("startDate") {
                if let dateString = self.petData?.startDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = Date()
                }
                $0.title = "開始日付"
                $0.disabled = true
            }
            <<< DateRow("endDate") {
                if let dateString = self.petData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString, dateFormat: DateCommon.dateFormat)
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.title = "終了日付"
                $0.disabled = true
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
                $0.value = self.petData?.minDays ?? 1
                $0.disabled = true
            }
            <<< PickerInputRow<Int>("maxDays"){
                $0.title = "最長"
                $0.value = self.petData?.maxDays ?? 30
                $0.disabled = true
            }
            +++ Section()
            <<< SwitchRow("enterDetails"){
                $0.title = "より詳細なプロフィールを入力する"
                $0.value = self.petData?.enterDetails ?? false
                $0.disabled = true
            }
            +++ Section("プロフィール（任意）"){
                $0.hidden = .function(["enterDetails"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    return row.value ?? false == false
                })
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.value = self.petData?.age ?? $0.options.first
                $0.disabled = true
            }
            <<< SegmentedRow<String>("size") {
                $0.title =  "大きさ"
                $0.options = Size.strings
                $0.value = self.petData?.size ?? $0.options.first
                $0.disabled = true
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
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
            }
            
            
            <<< PickerInputRow<String>("category"){
                $0.title = "品種"
                $0.value = self.petData?.category ?? nil
                $0.disabled = true
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
                $0.disabled = true
            }
            <<< CheckRow("isCastrated") {
                $0.title = "去勢/避妊手術済み"
                $0.value = self.petData?.isCastrated ?? false
                $0.disabled = true
            }
            <<< CheckRow("wanted") {
                $0.title = "里親募集中"
                $0.value = self.petData?.wanted ?? false
                $0.disabled = true
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
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
            }
            
            
            
            +++ Section(header: "おあずけ条件(任意)", footer: "おあずかりの際は、事前に確認しましょう"){
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
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
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
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
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
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
            }
            
            <<< SegmentedRow<String>("feeding"){
                $0.title =  "ごはんの回数/日"
                $0.options = ["1回","2回","3回"]
                $0.value = self.petData?.feeding ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("dentifrice") {
                $0.title = "歯磨きの回数/日"
                $0.options = ["1回","2回","3回"]
                $0.value = self.petData?.dentifrice ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("walk") {
                $0.title = "お散歩の回数/日"
                $0.options = ["不要","1回","2回"]
                $0.value = self.petData?.walk ?? nil
                $0.disabled = true
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
                $0.disabled = true
           }
           
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "飼い主にメッセージを送る"
                row.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
               }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.toMessages()
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "もどる"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.back()
        }
        print("DEBUG_PRINT: PetDetailViewController.viewDidLoad start")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func back() {
        print("DEBUG_PRINT: PetDetailViewController.back start")
        
        //前画面に戻る
        self.navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: PetDetailViewController.back end")
    }
    
    // Messageに画面遷移
    @IBAction func toMessages() {
        print("DEBUG_PRINT: PetDetailViewController.toMessages start")
        
        let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        let consentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Consent") as! ConsentViewController
        let userMessagesContainerViewController = UserMessagesContainerViewController(top: messagesViewController, under: consentViewController)

        // roomIdを取得
        let uid = UserDefaults.standard.string(forKey: DefaultString.Uid)
        let pid = (self.petData?.id)!
        let roomId = uid! + pid
        
        if self.petData?.createBy == uid {
            SVProgressHUD.showError(withStatus: "このペットの飼い主はあなたです")
        }else{
            // HUDで処理中を表示
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            // roomDataの取得
            let roomRef = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId)
            roomRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: PetDetailViewController.toMessages .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    print("DEBUG_PRINT: PetDetailViewController.toMessages roomDataを取得")

                    // roomDataをセットして画面遷移
                    userMessagesContainerViewController.roomData = RoomData(snapshot: snapshot, myId: roomId)
                    self.navigationController?.pushViewController(userMessagesContainerViewController, animated: true)
                    
                }else{
                    print("DEBUG_PRINT: PetDetailViewController.toMessages roomDataを新規作成")
                    var inputData = [String : Any]()
                    let time = NSDate.timeIntervalSinceReferenceDate
                    
                    inputData["userId"] = uid
                    inputData["userName"] = UserDefaults.standard.string(forKey: DefaultString.DisplayName)
                    inputData["userImageString"] = UserDefaults.standard.string(forKey: DefaultString.ImageString)
                    inputData["userArea"] = UserDefaults.standard.string(forKey: DefaultString.Area)
                    inputData["userAge"] = UserDefaults.standard.string(forKey: DefaultString.Age)
                    inputData["userSex"] = UserDefaults.standard.string(forKey: DefaultString.Sex)
                    //TODO: 評価実装後、活性
//                    inputData["userGoodInt"] = self.userDefaults?.string(forKey: DefaultString.Good)
//                    inputData["userBadInt"] = self.userDefaults?.string(forKey: DefaultString.Bad)
                    inputData["petId"] = pid
                    inputData["petName"] = self.petData?.name
                    inputData["petImageString"] = self.petData?.imageString
                    inputData["breederId"] = self.petData?.createBy
                    inputData["lastMessage"] = " "
                    inputData["createAt"] = String(time)
                    inputData["updateAt"] = String(time)
                    
                    // roomをinsert
                    let ref = FIRDatabase.database().reference()
                    ref.child(Paths.RoomPath).child(roomId).setValue(inputData)
                    // user,petをupdate
                    let childUpdates = ["/\(Paths.UserPath)/\(uid!)/roomIds/": true,
                                        "/\(Paths.PetPath)/\(pid)/roomIds/":true,
                                        "/\(Paths.UserPath)/\(self.petData!.createBy!)/roomIds/": true]
                    ref.updateChildValues(childUpdates)
                    
                    // roomDataの取得
                    roomRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                        print("DEBUG_PRINT: PetDetailViewController.toMessages .observeSingleEventイベントが発生しました。（２）")
                        if let _ = snapshot2.value as? NSDictionary {
                            
                            // roomDataをセットして画面遷移
                            userMessagesContainerViewController.roomData = RoomData(snapshot: snapshot2, myId: roomId)
                            self.navigationController?.pushViewController(userMessagesContainerViewController, animated: true)
                            
                        }
                    })
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            // HUDを消す
            SVProgressHUD.dismiss()
        }
        
        print("DEBUG_PRINT: PetDetailViewController.toMessages end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class PetDetailViewNib: UIView {
    
    @IBOutlet weak var petImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

