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
import FirebaseStorageUI
import SVProgressHUD
import SCLAlertView

class PetDetailViewController: BaseFormViewController {
    
    var petData: PetData?
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: PetDetailViewController.viewDidLoad start")
        
        if self.petData != nil, self.petData!.isAvailable!, DateCommon.stringToDate(self.petData!.endDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
            // 期限が過ぎているのに「おあずけ人募集中」のままの場合
            self.petData?.isAvailable = false
        }
        
        // フォーム
        form +++
            Section() {
                if let key = self.petData?.id {
                    var header = HeaderFooterView<PetDetailViewNib>(.nibFile(name: "PetDetailHeader", bundle: nil))
                    header.onSetupView = { (view, section) -> () in
                        view.petImageView.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
                        view.petImageView.alpha = 1;
                    }
                    $0.header = header
                }
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "シェアする"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "share")
                }
                .onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.share()
            }

            +++ Section("プロフィール")
            <<< NameRow("name") {
                $0.title = "名前"
                $0.value = self.petData?.name ?? nil
                $0.disabled = true
            }
            .cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "dogtag")
            }
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.value = self.petData?.area ?? nil
                $0.disabled = true
            }
            .cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "maker")
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
                row.title = "あずかり人のレビューを見る"
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
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "このペットの飼い主の情報"
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.showBreederDetail()
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "このペットを運営に通報＆ブロックする"
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.report()
        }

        print("DEBUG_PRINT: PetDetailViewController.viewDidLoad start")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: PetDetailViewController.viewWillDisappear start")
        
        if let userId = self.petData?.createBy {
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(userId)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: PetDetailViewController.viewWillDisappear end")
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func report() {
        print("DEBUG_PRINT: PetDetailViewController.report start")
        
        if self.petData?.createBy == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            SVProgressHUD.showError(withStatus: "このペットの飼い主はあなたです")
        }else{
            let alertView = SCLAlertView(appearance: SCLAlert.appearance)
            let textField = alertView.addTextField("違反内容など")
            let nameFeild = alertView.addTextField("あなたのお名前")
            let mailFeild = alertView.addTextField("あなたのメールアドレス")
            alertView.addButton("通報&ブロッックする"){
                if let violationContent = textField.text, let name = nameFeild.text ,let mail = mailFeild.text{
                    self.excuteReport(text: violationContent,mail:mail,name:name)
                }
            }
            alertView.addButton("キャンセル", target:self, selector:#selector(PetDetailViewController.cancel))
            alertView.showEdit("違反報告", subTitle: "\n違反内容について記載し、通報して下さい。\n通報後はこのペットからのメッセージをブロックし、Home画面にて非表示になります。\nブロックリストはメニューの 'BlockList' から編集可能です。")
        }
        print("DEBUG_PRINT: PetDetailViewController.report end")
    }

    func excuteReport(text :String, mail :String, name :String) {
        print("DEBUG_PRINT: PetDetailViewController.excuteReport start")
        
        var inputData = [String : Any]()
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        
        // DB保存（運営が参照するのみ）
        let key = ref.child(Paths.ViolationPetPath).childByAutoId().key
        inputData["mail"] = mail
        inputData["name"] = name
        inputData["text"] = text
        inputData["targetPetId"] = self.petData?.id
        inputData["createAt"] = String(time)
        inputData["createBy"] = UserDefaults.standard.string(forKey: DefaultString.Uid) ?? "guest"
        // insert
        ref.child(Paths.ViolationPetPath).child(key).setValue(inputData)
        // 表示用
        var blockedPets = [String]()
        if UserDefaults.standard.array(forKey: DefaultString.BlockedPetIds) != nil{
            for pid in UserDefaults.standard.array(forKey: DefaultString.BlockedPetIds) as! [String] {
                if pid == (self.petData?.id)! {
                    // なにもしない（重複登録対応）
                }else{
                    blockedPets.append((self.petData?.id)!)
                }
            }
        }
        blockedPets.append((self.petData?.id)!)
        UserDefaults.standard.set(blockedPets, forKey: DefaultString.BlockedPetIds)
        
        // メッセージブロック用（ユーザーがペットをブロック）
        if !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) ,let uid = UserDefaults.standard.string(forKey: DefaultString.Uid){
            // 既存のルームをブロック
            if self.petData?.roomIds != nil {
                for (roomId,_) in (self.petData?.roomIds)! {
                    if roomId.contains(uid) {
                        let childUpdates2 = ["/\(Paths.RoomPath)/\(roomId)/blocked/": uid] as [String : Any]
                        ref.updateChildValues(childUpdates2)
                    }
                }
            }
        }

        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "運営に違反報告が送信されました。")

        print("DEBUG_PRINT: PetDetailViewController.excuteReport end")
    }
    
    func cancel() {
        print("DEBUG_PRINT: PetDetailViewController.cancel start")
        print("DEBUG_PRINT: PetDetailViewController.cancel end")
    }
    
    @IBAction func showBreederDetail() {
        print("DEBUG_PRINT: PetDetailViewController.showBreederDetail start")
        
        if let userId = self.petData?.createBy {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: PetDetailViewController.showBreederDetail .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let userData = UserData(snapshot: snapshot, myId: userId)
                    let userDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailViewController
                    userDetailViewController.userData = userData
                    self.navigationController?.pushViewController(userDetailViewController, animated: true)
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        }
        
        print("DEBUG_PRINT: PetDetailViewController.showBreederDetail end")
    }

    @IBAction func back() {
        print("DEBUG_PRINT: PetDetailViewController.back start")
        
        if !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) && FIRAuth.auth()?.currentUser != nil {
            if !observing {
                // roomIdを取得
                let uid = UserDefaults.standard.string(forKey: DefaultString.Uid)
                let pid = (self.petData?.id)!
                let roomId = uid! + pid
                let roomRef = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId)
                roomRef.removeAllObservers()
            }
        }
        
        //前画面に戻る
        self.navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: PetDetailViewController.back end")
    }
    
    // Messageに画面遷移
    @IBAction func toMessages() {
        print("DEBUG_PRINT: PetDetailViewController.toMessages start")
        
        if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            // ユーザープロフィールが存在しない場合はクリック不可
            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            self.navigationController?.pushViewController(userViewController, animated: true)
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "飼い主さんとのやりとりには、プロフィール登録が必要です。")
            SVProgressHUD.dismiss(withDelay: 3)
        }else if FIRAuth.auth()?.currentUser == nil {
            let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! AccountViewController
            let navigationController = UINavigationController(rootViewController: accountViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "先にログインして下さい")
            SVProgressHUD.dismiss(withDelay: 3)
        }else{
            var blockedFlag = false
            // 自分がこのペットをブロックしている場合
            if let blockedPets = UserDefaults.standard.array(forKey: DefaultString.BlockedPetIds) {
                for pid in blockedPets as! [String] {
                    if pid == self.petData?.id {
                        blockedFlag = true
                    }
                }
            }
            // 自分がこのペットにブロックされている場合
            if self.petData?.blockingUser != nil{
                for (blockingUser,_) in (self.petData?.blockingUser)! {
                    if blockingUser == UserDefaults.standard.string(forKey: DefaultString.Uid){
                        blockedFlag = true
                    }
                }
            }
            
            if blockedFlag == false {
                let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserMessages") as! MessagesViewController
                let consentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Consent") as! ConsentViewController
                let userMessagesContainerViewController = UserMessagesContainerViewController(top: messagesViewController, under: consentViewController)
                
                // roomIdを取得
                let uid = UserDefaults.standard.string(forKey: DefaultString.Uid)
                let pid = (self.petData?.id)!
                let roomId = uid! + pid
                
                if self.petData?.createBy == uid {
                    SVProgressHUD.showError(withStatus: "このペットの飼い主はあなたです")
                }else{
                    self.observing = true
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
                            inputData["userArea"] = UserDefaults.standard.string(forKey: DefaultString.Area)
                            inputData["userAge"] = UserDefaults.standard.string(forKey: DefaultString.Age)
                            inputData["userSex"] = UserDefaults.standard.string(forKey: DefaultString.Sex)
                            inputData["userGoodInt"] = UserDefaults.standard.dictionary(forKey: DefaultString.Goods)
                            inputData["userBadInt"] = UserDefaults.standard.dictionary(forKey: DefaultString.Bads)
                            inputData["petId"] = pid
                            inputData["petName"] = self.petData?.name
                            inputData["breederId"] = self.petData?.createBy
                            inputData["lastMessage"] = " "
                            inputData["createAt"] = String(time)
                            inputData["updateAt"] = String(time)
                            
                            // roomをinsert
                            let ref = FIRDatabase.database().reference()
                            ref.child(Paths.RoomPath).child(roomId).setValue(inputData)
                            // user,petをupdate
                            let childUpdates = ["/\(Paths.UserPath)/\(uid!)/roomIds/\(roomId)/": true,
                                                "/\(Paths.PetPath)/\(pid)/roomIds/\(roomId)/":true,
                                                "/\(Paths.UserPath)/\(self.petData!.createBy!)/roomIds/\(roomId)/": true]
                            ref.updateChildValues(childUpdates)
                            
                            // roomDataの取得
                            roomRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                                print("DEBUG_PRINT: PetDetailViewController.toMessages .observeSingleEventイベントが発生しました。（２）")
                                if let _ = snapshot2.value as? NSDictionary {
                                    let roomData = RoomData(snapshot: snapshot2, myId: roomId)
                                    // roomDataをセットして画面遷移
                                    userMessagesContainerViewController.roomData = roomData
                                    self.navigationController?.pushViewController(userMessagesContainerViewController, animated: true)
                                    self.observing = false
                                }
                            })
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    // HUDを消す
                    SVProgressHUD.dismiss()
                }
            }else{
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "ブロック中です")
                SVProgressHUD.dismiss(withDelay: 3)
            }
        }
        
        print("DEBUG_PRINT: PetDetailViewController.toMessages end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toHistory() {
        print("DEBUG_PRINT: PetDetailViewController.toHistory start")
        
        // historyに画面遷移
        let historyViewController = self.storyboard?.instantiateViewController(withIdentifier: "History") as! HistoryViewController
        historyViewController.petData = self.petData
        self.navigationController?.pushViewController(historyViewController, animated: true)
        
        print("DEBUG_PRINT: PetDetailViewController.toHistory end")
    }
    
    @IBAction func share() {
        print("DEBUG_PRINT: PetDetailViewController.share start")
        
        // 共有する項目
        let shareText = ShareString.text
        let shareWebsite = ShareString.website
        // 画像を追加
        let view = UIImageView()
        var shareImage = UIImage()
        view.sd_setImage(with: StorageRef.getRiversRef(key: (self.petData?.id)!), placeholderImage: StorageRef.placeholderImage)
        if view.image != StorageRef.placeholderImage {
            shareImage = view.image!
        }
        let shareItems = [shareText, shareWebsite, shareImage] as [Any]
        // LINEで送るボタンを追加
        let line = LINEActivity()
        let avc = UIActivityViewController(activityItems: shareItems, applicationActivities: [line])
        present(avc, animated: true, completion: nil)
        
        print("DEBUG_PRINT: PetDetailViewController.share end")
    }

    
}

class PetDetailViewNib: UIView {
    
    @IBOutlet weak var petImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

