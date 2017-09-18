//
//  LeaveViewController.swift
//  Petto
//
//  Created by admin on 2017/08/09.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import FirebaseStorageUI
import SVProgressHUD
import SCLAlertView
import Toucan

class LeaveViewController: BaseViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    var conditionArray = [String]()
    var leaveData: LeaveData?
    var userData: UserData?
    var petData: PetData?
    var appearance1 :SCLAlertView.SCLAppearance?
    var photeImage: UIImage?
    var userComment: String?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var conditionsCollectionView: UICollectionView!
    @IBOutlet weak var excuteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: LeaveViewController.viewDidLoad start")
        
        conditionsCollectionView.delegate = self
        conditionsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "ConditionsCollectionViewCell", bundle: nil)
        conditionsCollectionView.register(nib, forCellWithReuseIdentifier: "ConditionsCell")
        
        self.getUser()
        self.getPet()
        self.setData()
        
        print("DEBUG_PRINT: LeaveViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: LeaveViewController.viewWillAppear start")
        
        // 自分があずかり人で、かつ、あずかり中もしくは過去あずかったの場合
        if UserDefaults.standard.object(forKey: "isInitialDisplay") != nil, UserDefaults.standard.bool(forKey: "isInitialDisplay") == true {
            if self.leaveData?.userId == UserDefaults.standard.string(forKey: DefaultString.Uid){
                if self.leaveData?.runningFlag == true || self.leaveData?.completeFlag == true || self.leaveData?.abortFlag == true {
                    UserDefaults.standard.set(true, forKey: "isInitialDisplay")
                    // ポップアップ表示、ボタン活性化
                    let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                    alertView.addButton("了解", target:self, selector:#selector(LeaveViewController.cancel))
                    alertView.showInfo("思い出フォト", subTitle: "\nあずかったペットとの写真を投稿できるようになりました！")
                }
            }
        }
        print("DEBUG_PRINT: LeaveViewController.viewWillAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: LeaveViewController.viewWillDisappear start")
        
        if let pid = self.leaveData?.petId {
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(pid)
            ref.removeAllObservers()
        }
        if let uid = self.leaveData?.userId {
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: LeaveViewController.viewWillDisappear end")
    }
    
    
    func setData() {
        print("DEBUG_PRINT: LeaveViewController.setData start")
        
        if self.leaveData?.userId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            // 自分があずかり人の場合
            self.termLabel.text = "あずかり期間"
        }else{
            // 自分がブリーダーの場合
            self.termLabel.text = "おあずけ期間"
        }
        // imageをstorageから直接ロード
        self.userImageView.sd_setImage(with: StorageRef.getRiversRef(key: (self.leaveData?.userId)!), placeholderImage: StorageRef.placeholderImage)
        self.petImageView.sd_setImage(with: StorageRef.getRiversRef(key: (self.leaveData?.petId)!), placeholderImage: StorageRef.placeholderImage)
        self.startDateLabel.text = "開始：" + DateCommon.displayDate(stringDate: (self.leaveData?.startDate)!)
        self.endDateLabel.text = "終了：" + DateCommon.displayDate(stringDate: (self.leaveData?.endDate)!)

        let endDate = DateCommon.stringToDate((self.leaveData?.endDate)!, dateFormat: DateCommon.dateFormat)
       
        // ボタン制御
        if leaveData?.acceptFlag == true &&
            leaveData?.runningFlag == false &&
            leaveData?.stopFlag == false &&
            leaveData?.abortFlag == false &&
            leaveData?.completeFlag == false {
            
            // 未実行
            if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                // 自分がブリーダーの場合
                self.excuteButton.setTitle("おあずけを開始する！", for: .normal)
                self.cancelButton.setTitle("やっぱりやめる", for: .normal)
                self.cancelButton.backgroundColor =  UIColor(red: 1.0, green: 0.498, blue: 0.314, alpha: 1.0)
            }else{
                // 自分があずかり人の場合
                self.excuteButton.setTitle("おあずけ開始(飼い主のみ可)", for: .normal)
                self.cancelButton.setTitle("キャンセル(飼い主のみ可)", for: .normal)
                self.excuteButton.isEnabled = false
                self.cancelButton.isEnabled = false
            }
        }else if leaveData?.acceptFlag == true &&
            leaveData?.runningFlag == true &&
            leaveData?.stopFlag == false &&
            leaveData?.abortFlag == false &&
            leaveData?.completeFlag == false {

            // 実行中
            if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                // 自分がブリーダーの場合
                if endDate.compare(Date()) == ComparisonResult.orderedDescending {
                    // 期間内
                    self.excuteButton.setTitle("おあずけ中です", for: .normal)
                    self.cancelButton.setTitle("中断する", for: .normal)
                    self.cancelButton.backgroundColor =  UIColor(red: 1.0, green: 0.498, blue: 0.314, alpha: 1.0)
                    self.excuteButton.isEnabled = false
                }else{
                    // 期間外
                    self.excuteButton.setTitle("おあずけを終了する！", for: .normal)
                    self.cancelButton.isHidden = true
                }
            } else {
                // 自分があずかり人の場合
                self.excuteButton.setTitle("思い出フォトをアップする！", for: .normal)
                self.excuteButton.isEnabled = true
                if self.leaveData?.userComment != nil || self.leaveData?.breederComment != nil {
                    self.cancelButton.setTitle("思い出フォトを確認する", for: .normal)
                    self.cancelButton.backgroundColor = UIColor(red: 1.0, green: 0.498, blue: 0.314, alpha: 1.0)
                    self.cancelButton.isEnabled = true
                }else{
                    self.cancelButton.setTitle("中断する(飼い主のみ可)", for: .normal)
                    self.cancelButton.isEnabled = false
                }
            }
        }else if leaveData?.acceptFlag == true &&
            leaveData?.runningFlag == false &&
            leaveData?.stopFlag == false,
            leaveData?.abortFlag == true || leaveData?.completeFlag == true {
            // 終了済（中断・完了）
            // excute
            if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                // 自分がブリーダーの場合
                self.excuteButton.setTitle("終了しました", for: .normal)
                self.excuteButton.isEnabled = false
            } else {
                // 自分があずかり人の場合
                self.excuteButton.setTitle("思い出フォトをアップする！", for: .normal)
                self.excuteButton.isEnabled = true
            }
            // cancel
            if self.leaveData?.userComment != nil || self.leaveData?.breederComment != nil {
                self.cancelButton.setTitle("思い出フォトを確認する", for: .normal)
                self.cancelButton.backgroundColor = UIColor(red: 1.0, green: 0.498, blue: 0.314, alpha: 1.0)
                self.cancelButton.isEnabled = true
            }else{
                self.cancelButton.isHidden = true
            }
        }else{
            // 終了済（中止）
            self.excuteButton.setTitle("中止されました", for: .normal)
            self.excuteButton.isEnabled = false
            self.cancelButton.isHidden = true
        }
        
        print("DEBUG_PRINT: LeaveViewController.setData end")
    }
    
    @IBAction func toPetDetailButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.toPetDetailButton start")
        
        // PetDetailに画面遷移
        let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
        petDetailViewController.petData = self.petData
        self.navigationController?.pushViewController(petDetailViewController, animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.toPetDetailButton end")
    }

    func getPet() {
        print("DEBUG_PRINT: LeaveViewController.getPet start")
        
        // Firebaseから登録済みデータを取得
        if let pid = self.leaveData?.petId {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(pid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: LeaveViewController.getPet .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    self.petData = PetData(snapshot: snapshot, myId: pid)
                }
                DispatchQueue.main.async {
                    if self.petData?.enterDetails == true {
                        for code in Environment.codes {
                            for (key,val) in (self.petData?.environments)! {
                                if key == code && val {
                                    self.conditionArray.append(Environment.toIcon(code))
                                }
                            }
                        }
                        for code in Tool.codes {
                            for (key,val) in (self.petData?.tools)! {
                                if key == code && val {
                                    self.conditionArray.append(Tool.toIcon(code))
                                }
                            }
                        }
                        for code in PetNGs.codes {
                            for (key,val) in (self.petData?.ngs)! {
                                if key == code && val {
                                    self.conditionArray.append(PetNGs.toIcon(code))
                                }
                            }
                        }
                        for code in UserNGs.codes {
                            for (key,val) in (self.petData?.userNgs)! {
                                if key == code && val {
                                    self.conditionArray.append(UserNGs.toIcon(code))
                                }
                            }
                        }
                    }
                    if self.conditionArray.count == 0 {
                        self.conditionArray.append("no-data")
                    }
                }
                print("DEBUG_PRINT: LeaveViewController.getPet [DispatchQueue.main.async] \(self.conditionArray)")
                self.conditionsCollectionView.reloadData()
                SVProgressHUD.dismiss()
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        print("DEBUG_PRINT: LeaveViewController.getPet end")
    }
    
    @IBAction func toUserDetailButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.toUserDetailButton start")
        
        // UserDetailに画面遷移
        let userDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailViewController
        userDetailViewController.userData = self.userData
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.toUserDetailButton end")
    }

    func getUser() {
        print("DEBUG_PRINT: LeaveViewController.getUser start")
        
        // Firebaseから登録済みデータを取得
        if let uid = self.leaveData?.userId {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: LeaveViewController.getUser .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    self.userData = UserData(snapshot: snapshot, myId: uid)
                }
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: LeaveViewController.getUser [DispatchQueue.main.async]")
                    self.conditionsCollectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        print("DEBUG_PRINT: LeaveViewController.getUser end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        print("DEBUG_PRINT: LeaveViewController.cellForItemAt start")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConditionsCell", for: indexPath) as! ConditionsCollectionViewCell
        if self.userData != nil && self.petData != nil{
            cell.setData(iconString: self.conditionArray[indexPath.row], userData: self.userData!)
        }
        print("DEBUG_PRINT: LeaveViewController.cellForItemAt end")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("DEBUG_PRINT: LeaveViewController.sizeForItemAt start")
        
        var size = CGSize.zero
        if self.conditionArray.count == 1 && self.conditionArray.first == "no-data" {
            size = CGSize(width: self.conditionsCollectionView.frame.size.width, height: self.conditionsCollectionView.frame.size.height)
        }else{
            size = CGSize(width: 70, height: 50)
        }
        
        print("DEBUG_PRINT: LeaveViewController.sizeForItemAt end")
        return size
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return self.conditionArray.count
    }
    
    @IBAction func handleExcuteButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.handleExcuteButton start")
        
        let startDate = DateCommon.stringToDate((self.leaveData?.startDate)!, dateFormat: DateCommon.dateFormat)
        let endDate = DateCommon.stringToDate((self.leaveData?.endDate)!, dateFormat: DateCommon.dateFormat)
        
        if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            // ブリーダーの場合
            if leaveData?.acceptFlag == true &&
                leaveData?.runningFlag == false &&
                leaveData?.stopFlag == false &&
                leaveData?.abortFlag == false &&
                leaveData?.completeFlag == false {
                // 未実行
                if startDate.compare(Date()) == ComparisonResult.orderedDescending {
                    // 期間前
                    let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                    alertView.addButton("引き渡し完了", target:self, selector:#selector(LeaveViewController.excuted))
                    alertView.addButton("まだ", target:self, selector:#selector(LeaveViewController.cancel))
                    alertView.showWarning("予定を早めますか？", subTitle: "\nおあずけを開始する場合は、ペットを引き渡して下さい。\n\n※トラブル防止のため、あずかり人の連絡先・住所の確認を推奨します。")
                }else if endDate.compare(Date()) == ComparisonResult.orderedAscending {
                    // 期間後
                    let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                    alertView.addButton("引き渡し完了", target:self, selector:#selector(LeaveViewController.excuted))
                    alertView.addButton("まだ", target:self, selector:#selector(LeaveViewController.cancel))
                    alertView.showWarning("予定日を過ぎています", subTitle: "\nおあずけを開始する場合は、ペットを引き渡して下さい。\n\n※トラブル防止のため、あずかり人の連絡先・住所の確認を推奨します。")
                }else{
                    // 期間中
                    let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                    alertView.addButton("引き渡し完了", target:self, selector:#selector(LeaveViewController.excuted))
                    alertView.addButton("まだ", target:self, selector:#selector(LeaveViewController.cancel))
                    alertView.showSuccess("ペットを引き渡して下さい", subTitle: "\nトラブル防止のため、\nあずかり人の連絡先・住所の確認を推奨します。")
                }
            }else if leaveData?.acceptFlag == true &&
                leaveData?.runningFlag == true &&
                leaveData?.stopFlag == false &&
                leaveData?.abortFlag == false &&
                leaveData?.completeFlag == false {
                // 実行中
                let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                alertView.addButton("引き取り完了", target:self, selector:#selector(LeaveViewController.complete))
                alertView.addButton("まだ", target:self, selector:#selector(LeaveViewController.cancel))
                alertView.showSuccess("ペットを引き取って下さい", subTitle: "\nペットに異常がないか、ペットが迷惑をかけなかったかなど確認しましょう。")
            }
        }else{
            // あずかり人の場合
            let alertView = SCLAlertView(appearance: SCLAlert.appearance)
            let textField = alertView.addTextField("コメントなど")
            alertView.addButton("思い出フォトをアップ"){
                self.userComment = textField.text
                self.updateCommemorativePhote()
            }
            alertView.addButton("キャンセル", target:self, selector:#selector(LeaveViewController.cancel))
            alertView.showEdit("思い出フォト", subTitle: "\nあずかりに関するコメントと写真をアップします。\nコメントと写真は他のユーザーにも公開されます")
        }
        
        print("DEBUG_PRINT: LeaveViewController.handleExcuteButton end")
    }

    
    @IBAction func handleCancelButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.handleCancelButton start")
        
        if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            // ブリーダーの場合
            if leaveData?.acceptFlag == true &&
                leaveData?.runningFlag == false &&
                leaveData?.stopFlag == false &&
                leaveData?.abortFlag == false &&
                leaveData?.completeFlag == false {
                // 未実行
                let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                alertView.addButton("おあずけ中止", target:self, selector:#selector(LeaveViewController.stop))
                alertView.addButton("なんでもない", target:self, selector:#selector(LeaveViewController.cancel))
                alertView.showWarning("おあずけを中止しますか？", subTitle: "\n中止すると、あずかり人にも通知されます。")
            }else if leaveData?.acceptFlag == true &&
                leaveData?.runningFlag == true &&
                leaveData?.stopFlag == false &&
                leaveData?.abortFlag == false &&
                leaveData?.completeFlag == false {
                // 実行中
                let alertView = SCLAlertView(appearance: SCLAlert.appearance)
                alertView.addButton("おあずけ中断", target:self, selector:#selector(LeaveViewController.abort))
                alertView.addButton("なんでもない", target:self, selector:#selector(LeaveViewController.cancel))
                alertView.showWarning("おあずけを中断しますか？", subTitle: "\n中断する前に、ペットを引き取りましょう。")
            }else{
                // 完了・中断済みの場合、ヒストリー画面に遷移
                let historyViewController = self.storyboard?.instantiateViewController(withIdentifier: "History") as! HistoryViewController
                historyViewController.petData = self.petData
                self.navigationController?.pushViewController(historyViewController, animated: true)
            }
        }else{
            // あずかり人の場合
            // ヒストリー画面に遷移
            let historyViewController = self.storyboard?.instantiateViewController(withIdentifier: "History") as! HistoryViewController
            historyViewController.petData = self.petData
            self.navigationController?.pushViewController(historyViewController, animated: true)
        }
        
        print("DEBUG_PRINT: LeaveViewController.handleCancelButton end")
    }
    
    @IBAction func handleBackButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.handleBackButton start")
        
        //前画面に戻る
        self.navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.handleBackButton end")
    }
    
    func excuted(){
        print("DEBUG_PRINT: LeaveViewController.excuted start")
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "excuted" as NSObject,
            kFIRParameterItemID: "4" as NSObject
            ])

        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveData!.id!)/runningFlag/": true,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/actualStartDate/": Date().description,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/updateAt/": String(time),
                            "/\(Paths.PetPath)/\(self.leaveData!.petId!)/historys/\(self.leaveData!.id!)": true,
                            "/\(Paths.PetPath)/\(self.leaveData!.petId!)/runningFlag/": true,
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/todoRoomIds/\(self.leaveData!.id!)/": true] as [String : Any]
        ref.updateChildValues(childUpdates)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
                
        print("DEBUG_PRINT: LeaveViewController.excuted end")
    }
    func complete(){
        print("DEBUG_PRINT: LeaveViewController.complete start")
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "complete" as NSObject,
            kFIRParameterItemID: "5" as NSObject
            ])
        
        var breederComment: String?
        var goods = self.userData?.goods
        var bads = self.userData?.bads
        
        // ユーザ評価
        let alertView = SCLAlertView(appearance: SCLAlert.appearance)
        let textField = alertView.addTextField("コメントなど")
        alertView.addButton("Good!!"){
            breederComment = textField.text
            goods?.append((self.leaveData?.breederId)!)
            self.completeUpdateFIR(breederComment: breederComment, goods: goods, bads: bads)
        }
        alertView.addButton("Bad..."){
            breederComment = textField.text
            bads?.append((self.leaveData?.breederId)!)
            self.completeUpdateFIR(breederComment: breederComment, goods: goods, bads: bads)
        }
        alertView.showEdit("お疲れさまでした", subTitle: "\nあずかり人を評価して下さい。")
        
        print("DEBUG_PRINT: LeaveViewController.complete end")
    }
    
    func completeUpdateFIR(breederComment: String?, goods: [String]?, bads: [String]? ){
        print("DEBUG_PRINT: LeaveViewController.completeUpdateFIR start")

        let id = self.leaveData?.id!
        let uid = self.leaveData?.userId!
        let bid = self.leaveData?.breederId!
        let good = goods ?? []
        let bad = bads ?? []
        let com = breederComment ?? "[コメントはありません]"
        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(id!)/runningFlag/": false,
                            "/\(Paths.LeavePath)/\(id!)/completeFlag/": true,
                            "/\(Paths.LeavePath)/\(id!)/breederComment/": com,
                            "/\(Paths.LeavePath)/\(id!)/userGoodInt/": good.count,
                            "/\(Paths.LeavePath)/\(id!)/userBadInt/": bad.count,
                            "/\(Paths.LeavePath)/\(id!)/actualEndDate/": Date().description,
                            "/\(Paths.LeavePath)/\(id!)/updateAt/": String(time),
                            "/\(Paths.PetPath)/\(self.leaveData!.petId!)/runningFlag/": false,
                            "/\(Paths.UserPath)/\(uid!)/goods/": good,
                            "/\(Paths.UserPath)/\(uid!)/bads/": bad,
                            "/\(Paths.UserPath)/\(uid!)/todoRoomIds/\(id!)/": false,
                            "/\(Paths.UserPath)/\(bid!)/todoRoomIds/\(id!)/": false] as [String : Any]
        ref.updateChildValues(childUpdates)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.completeUpdateFIR end")
    }
    
    
    func stop(){
        print("DEBUG_PRINT: LeaveViewController.stop start")
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "stop" as NSObject,
            kFIRParameterItemID: "4" as NSObject
            ])

        var breederComment: String?
        // 中止理由
        let alertView = SCLAlertView(appearance: SCLAlert.appearance)
        let textField = alertView.addTextField("急な予定が入ったから")
        alertView.addButton("OK"){
            breederComment = textField.text
            self.stopUpdateFIR(breederComment: breederComment)
        }
        alertView.showEdit("中止します", subTitle: "\n中止の理由を入力して下さい。")
        
        print("DEBUG_PRINT: LeaveViewController.stop end")
    }
    
    func stopUpdateFIR(breederComment: String?){
        print("DEBUG_PRINT: LeaveViewController.stopUpdateFIR start")
        
        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveData!.id!)/runningFlag/": false,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/stopFlag/": true,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/breederComment/": breederComment ?? "[コメントはありません]",
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/actualEndDate/": Date().description,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/updateAt/": String(time),
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/todoRoomIds/\(self.leaveData!.id!)/": false,
                            "/\(Paths.UserPath)/\(self.leaveData!.breederId!)/todoRoomIds/\(self.leaveData!.id!)/": false] as [String : Any]
        ref.updateChildValues(childUpdates)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.stopUpdateFIR end")
    }
    
    func abort(){
        print("DEBUG_PRINT: LeaveViewController.abort start")
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "abort" as NSObject,
            kFIRParameterItemID: "5" as NSObject
            ])

        var breederComment: String?
        var goods = self.userData?.goods
        var bads = self.userData?.bads
        // 中断理由
        let alertView = SCLAlertView(appearance: SCLAlert.appearance)
        let textField = alertView.addTextField("ペットが病気になったから")
        alertView.addButton("Good!!"){
            breederComment = textField.text
            goods?.append((self.leaveData?.breederId)!)
            self.abortUpdateFIR(breederComment: breederComment, goods: goods, bads: bads)
        }
        alertView.addButton("Bad..."){
            breederComment = textField.text
            bads?.append((self.leaveData?.breederId)!)
            self.abortUpdateFIR(breederComment: breederComment, goods: goods, bads: bads)
        }
        alertView.showEdit("中断します", subTitle: "\n中断の理由を入力し、\nあずかり人を評価して下さい。")
        
        print("DEBUG_PRINT: LeaveViewController.abort end")
    }
    
    func abortUpdateFIR(breederComment: String?, goods: [String]?, bads: [String]? ){
        print("DEBUG_PRINT: LeaveViewController.abortUpdateFIR start")
        
        let id = self.leaveData?.id!
        let uid = self.leaveData?.userId!
        let bid = self.leaveData?.breederId!
        let good = goods ?? []
        let bad = bads ?? []
        let com = breederComment ?? "[コメントはありません]"
        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(id!)/runningFlag/": false,
                            "/\(Paths.LeavePath)/\(id!)/abortFlag/": true,
                            "/\(Paths.LeavePath)/\(id!)/breederComment/": com,
                            "/\(Paths.LeavePath)/\(id!)/userGoodInt/": good.count,
                            "/\(Paths.LeavePath)/\(id!)/userBadInt/": bad.count,
                            "/\(Paths.LeavePath)/\(id!)/actualEndDate/": Date().description,
                            "/\(Paths.LeavePath)/\(id!)/updateAt/": String(time),
                            "/\(Paths.PetPath)/\(self.leaveData!.petId!)/runningFlag/": false,
                            "/\(Paths.UserPath)/\(uid!)/goods/": good,
                            "/\(Paths.UserPath)/\(uid!)/bads/": bad,
                            "/\(Paths.UserPath)/\(uid!)/todoRoomIds/\(id!)/": false,
                            "/\(Paths.UserPath)/\(bid!)/todoRoomIds/\(id!)/": false] as [String : Any]
        ref.updateChildValues(childUpdates)

        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.abortUpdateFIR end")
    }
    
    func cancel(){
        print("DEBUG_PRINT: LeaveViewController.cancel start")
        // なにもしない
        print("DEBUG_PRINT: LeaveViewController.cancel end")
    }
    
    func toHistory() {
        print("DEBUG_PRINT: LeaveViewController.toHistory start")
        
        if self.photeImage != nil {
            // leaveをupdate
            storageUpload(photeImage: photeImage!, key: self.leaveData!.id!)
            let time = NSDate.timeIntervalSinceReferenceDate
            let ref = FIRDatabase.database().reference()
            let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveData!.id!)/userComment/": self.userComment ?? "[コメントはありません]",
                                "/\(Paths.LeavePath)/\(self.leaveData!.id!)/updateAt/": String(time)] as [String : Any]
            ref.updateChildValues(childUpdates)
        }
        
        print("DEBUG_PRINT: LeaveViewController.toHistory end")
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

    /*    // カメラがタップされたらカメラを起動して写真を取得
     func commemorativePhoteUpdate() {
     print("DEBUG_PRINT: LeaveViewController.commemorativePhoteUpdate start")
     
     let imageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
     imageSelectViewController.resultHandler = { commemorativePhote in
     self.photeImage = commemorativePhote
     self.toHistory()
     }
     
     print("DEBUG_PRINT: LeaveViewController.commemorativePhoteUpdate end")
     }
     */
    // カメラがタップされたらカメラを起動して写真を取得
    func updateCommemorativePhote() {
        print("DEBUG_PRINT: LeaveViewController.updateCommemorativePhote start")
        
        let imageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        imageSelectViewController.delegate = self
        self.navigationController?.pushViewController(imageSelectViewController, animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.updateCommemorativePhote end")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] {
            setImage(image: image as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func setImage(image: UIImage){
        self.photeImage = Toucan(image: image).resize(CGSize(width: 200, height: 200), fitMode: Toucan.Resize.FitMode.clip).image
        self.toHistory()
    }
    
    

}
extension LeaveViewController: ImageSelectViewDelegate{
    
    func didCompletion(image :UIImage){
        setImage(image: image)
    }
}

