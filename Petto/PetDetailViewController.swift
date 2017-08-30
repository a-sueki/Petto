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
    
    let userDefaults = UserDefaults.standard
    var petData: PetData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
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
                        
                        view.petImageView.alpha = 0;
                        UIView.animate(withDuration: 2.0, animations: { [weak view] in
                            view?.petImageView.alpha = 1
                        })
                        view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view] in
                            view?.layer.transform = CATransform3DIdentity
                        })
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
                $0.title = "注意事項"
                $0.options = UserNGs.strings
                if let data = self.petData , data.userNgs.count > 0 {
                    let codes = Array(data.userNgs.keys)
                    $0.value = UserNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
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
                    let codes = Array(data.environments.keys)
                    $0.value = Environment.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
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
                $0.disabled = true
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
                $0.disabled = true
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
                    $0.value = DateCommon.stringToDate(dateString)
                }else{
                    $0.value = Date()
                }
                $0.title = "開始日付"
                $0.disabled = true
            }
            <<< DateRow("endDate") {
                if let dateString = self.petData?.endDate {
                    $0.value = DateCommon.stringToDate(dateString)
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
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.toMessages()
        }
        print("DEBUG_PRINT: PetDetailViewController.viewDidLoad start")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // Messageに画面遷移
    @IBAction func toMessages() {
        print("DEBUG_PRINT: PetDetailViewController.toMessages start")
        
        // HUDで処理中を表示
        SVProgressHUD.show()

        let messagesContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessagesContainer") as! MessagesContainerViewController
        
        // roomIdを取得
        let uid = userDefaults.string(forKey: DefaultString.Uid)!
        let pid = (self.petData?.id)!
        let roomId = uid + pid
        
        // roomDataの取得
        let roomRef = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId)
        roomRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: PetDetailViewController.toMessages .observeSingleEventイベントが発生しました。")
            if let _ = snapshot.value as? NSDictionary {
                print("DEBUG_PRINT: PetDetailViewController.toMessages roomDataを取得")
                // roomDataをセットして画面遷移
                messagesContainerViewController.roomData = RoomData(snapshot: snapshot, myId: roomId)
                self.navigationController?.pushViewController(messagesContainerViewController, animated: true)
            }else{
                print("DEBUG_PRINT: PetDetailViewController.toMessages roomDataを新規作成")
                var inputData = [String : Any]()
                let time = NSDate.timeIntervalSinceReferenceDate
                
                inputData["userId"] = uid
                inputData["userName"] = self.userDefaults.string(forKey: DefaultString.DisplayName)
                inputData["userImageString"] = self.userDefaults.string(forKey: DefaultString.Phote)
                inputData["petId"] = pid
                inputData["petName"] = self.petData?.name
                inputData["petImageString"] = self.petData?.imageString
                
                inputData["createAt"] = String(time)
                inputData["updateAt"] = String(time)
                
                // insert
                let ref = FIRDatabase.database().reference()
                ref.child(Paths.RoomPath).child(roomId).setValue(inputData)
                // update
                ref.child(Paths.UserPath).child(uid).child("myMessages").updateChildValues([roomId : true])
                ref.child(Paths.PetPath).child(pid).child("myMessages").updateChildValues([roomId : true])

                // roomDataの取得
                roomRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                    print("DEBUG_PRINT: PetDetailViewController.toMessages .observeSingleEventイベントが発生しました。（２）")
                    if let _ = snapshot2.value as? NSDictionary {
                        // roomDataをセットして画面遷移
                        messagesContainerViewController.roomData = RoomData(snapshot: snapshot2, myId: roomId)
                        self.navigationController?.pushViewController(messagesContainerViewController, animated: true)
                    }
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // HUDを消す
        SVProgressHUD.dismiss()

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

