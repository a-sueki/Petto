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
        
        // Cell初期設定
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
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
            
            +++ Section("プロフィール")
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = Sex.strings
                $0.value = self.petData?.sex ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.options = Kind.strings
                $0.value = self.petData?.kind ?? nil
                $0.disabled = true
            }
            <<< PickerInputRow<String>("category"){
                $0.title = "品種"
                $0.value = self.petData?.category ?? nil
                $0.disabled = true
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.value = self.petData?.age ?? $0.options.first
                $0.disabled = true
            }
            
            +++ Section("状態")
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
            
            
            +++ Section()
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
                $0.value = self.petData?.isAvailable ?? false
                $0.disabled = true
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
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
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
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
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
            Section("おあずけ可能期間"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
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
            Section("連続おあずけ日数"){
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
            //TODO: その他、特記事項入力フォーム
            
            
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
            SVProgressHUD.show()
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
                    //TODO: 評価実装後、活性
//                    inputData["userGoodInt"] = self.userDefaults?.string(forKey: DefaultString.Good)
//                    inputData["userBadInt"] = self.userDefaults?.string(forKey: DefaultString.Bad)
                    inputData["petId"] = pid
                    inputData["petName"] = self.petData?.name
                    inputData["petImageString"] = self.petData?.imageString
//                    inputData["userOpenedFlg"] = true
//                    inputData["petOpenedFlg"] = false
                    inputData["breederId"] = self.petData?.createBy
                    inputData["lastMessage"] = " "
                    inputData["createAt"] = String(time)
                    inputData["updateAt"] = String(time)
                    
                    // insert
                    let ref = FIRDatabase.database().reference()
                    ref.child(Paths.RoomPath).child(roomId).setValue(inputData)
                    // update
                    ref.child(Paths.UserPath).child(uid!).child("roomIds").updateChildValues([roomId : true]) // あずかり人
                    ref.child(Paths.PetPath).child(pid).child("roomIds").updateChildValues([roomId : true])
                    ref.child(Paths.UserPath).child((self.petData?.createBy)!).child("roomIds").updateChildValues([roomId : true]) // ブリーダー
                    
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

