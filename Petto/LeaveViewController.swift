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
import SVProgressHUD
import SCLAlertView

class LeaveViewController: BaseViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    var conditionArray = [String]()
    var leaveData: LeaveData?
    var userData: UserData?
    var petData: PetData?
    var appearance1 :SCLAlertView.SCLAppearance?
    
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
        
        self.appearance1 = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "Helvetica", size: 17)!,
            kTextFont: UIFont(name: "Helvetica", size: 14)!,
            kButtonFont: UIFont(name: "Helvetica", size: 14)!,
            showCloseButton: false
        )
        
        print("DEBUG_PRINT: LeaveViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: LeaveViewController.viewWillAppear start")
        
        // 自分があずかり人で、かつ、あずかり中の場合
        if self.leaveData?.userId == UserDefaults.standard.string(forKey: DefaultString.Uid){
            if self.leaveData?.runningFlag == true || self.leaveData?.completeFlag == true || self.leaveData?.abortFlag == true {
                // ポップアップ表示、ボタン活性化
                let alertView = SCLAlertView(appearance: self.appearance1!)
                alertView.addButton("了解", target:self, selector:#selector(LeaveViewController.cancel))
                alertView.showInfo("思い出フォト", subTitle: "\nあずかったペットとの写真を投稿できるようになりました！")
                
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
        self.userImageView.image = self.leaveData?.userImage
        self.petImageView.image = self.leaveData?.petImage
        self.startDateLabel.text = "開始：" + DateCommon.displayDate(stringDate: (self.leaveData?.startDate)!)
        self.endDateLabel.text = "終了：" + DateCommon.displayDate(stringDate: (self.leaveData?.endDate)!)
        
        let startDate = DateCommon.stringToDate((self.leaveData?.startDate)!, dateFormat: DateCommon.dateFormat)
        let endDate = DateCommon.stringToDate((self.leaveData?.endDate)!, dateFormat: DateCommon.dateFormat)
        
        // ボタン制御
        if startDate.compare(Date()) == ComparisonResult.orderedDescending {
            // 期間前（startDateが今日よりも未来）
            if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                // 自分がブリーダーの場合
                self.excuteButton.setTitle("おあずけを開始する！", for: .normal)
                self.cancelButton.setTitle("やっぱりやめる", for: .normal)
                self.excuteButton.isEnabled = false
            }else{
                // 自分があずかり人の場合
                self.excuteButton.setTitle("おあずけ開始(飼い主のみ可)", for: .normal)
                self.cancelButton.setTitle("キャンセル(飼い主のみ可)", for: .normal)
                self.excuteButton.isEnabled = false
                self.cancelButton.isEnabled = false
            }
        } else if startDate.compare(Date()) == ComparisonResult.orderedAscending && endDate.compare(Date()) == ComparisonResult.orderedDescending{
            // 期間中（startDate < 今日 < endDate）
            if (self.leaveData?.runningFlag)! {
                // 実行中の場合
                if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                    // 自分がブリーダーの場合
                    self.excuteButton.setTitle("おあずけ中です", for: .normal)
                    self.cancelButton.setTitle("中断する", for: .normal)
                    self.excuteButton.isEnabled = false
                } else {
                    // 自分があずかり人の場合
                    self.excuteButton.setTitle("あずかり中です", for: .normal)
                    self.cancelButton.setTitle("中断する(飼い主のみ可)", for: .normal)
                    self.excuteButton.isEnabled = false
                    self.cancelButton.isEnabled = false
                }
            }else{
                // 未実行の場合
                if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                    // 自分がブリーダーの場合
                    self.excuteButton.setTitle("おあずけを開始する！", for: .normal)
                    self.cancelButton.setTitle("やっぱりやめる", for: .normal)
                }else{
                    // 自分があずかり人の場合
                    self.excuteButton.setTitle("おあずけ開始(飼い主のみ可)", for: .normal)
                    self.cancelButton.setTitle("キャンセル(飼い主のみ可)", for: .normal)
                    self.excuteButton.isEnabled = false
                    self.cancelButton.isEnabled = false
                }
            }
        } else {
            // 期間後（endDateが今日よりも過去）
            if self.leaveData?.runningFlag == true {
                if self.leaveData?.completeFlag == false && self.leaveData?.abortFlag == false {
                    // 実行中の場合
                    if self.leaveData?.breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
                        // 自分がブリーダーの場合
                        self.excuteButton.setTitle("おあずけを終了する！", for: .normal)
                        self.cancelButton.isHidden = true
                    }else{
                        // 自分があずかり人の場合
                        self.excuteButton.setTitle("あずかり終了(飼い主のみ可)", for: .normal)
                        self.excuteButton.isEnabled = false
                        self.cancelButton.isHidden = true
                    }
                }else{
                    // 完了・中断済みの場合
                    self.excuteButton.setTitle("終了しました", for: .normal)
                    self.excuteButton.isEnabled = false
                    self.cancelButton.isHidden = true
                }
            } else {
                // 未実行の場合
                self.excuteButton.setTitle("終了しました(未実施)", for: .normal)
                self.excuteButton.isEnabled = false
                self.cancelButton.isHidden = true
                
                //TODO:自動でTODOバッチをOFFに。leaveの更新は？
            }
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
        
        if self.leaveData?.runningFlag == false {
            // 開始
            let alertView = SCLAlertView(appearance: self.appearance1!)
            alertView.addButton("引き渡し完了", target:self, selector:#selector(LeaveViewController.excuted))
            alertView.addButton("ちょっと待って...", target:self, selector:#selector(LeaveViewController.cancel))
            alertView.showSuccess("ペットを引き渡して下さい", subTitle: "\nトラブル防止のため、\nあずかり人の連絡先・住所の確認を推奨します。")
        } else {
            // 完了
            let alertView = SCLAlertView(appearance: self.appearance1!)
            alertView.addButton("引き取り完了", target:self, selector:#selector(LeaveViewController.complete))
            alertView.addButton("ちょっと待って...", target:self, selector:#selector(LeaveViewController.cancel))
            alertView.showSuccess("ペットを引き取って下さい", subTitle: "\nペットに異常がないか、ペットが迷惑をかけなかったかなど確認しましょう。")
        }
        
        print("DEBUG_PRINT: LeaveViewController.handleExcuteButton end")
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.handleCancelButton start")
        
        if self.leaveData?.runningFlag == false {
            // 中止
            let alertView = SCLAlertView(appearance: self.appearance1!)
            alertView.addButton("おあずけ中止", target:self, selector:#selector(LeaveViewController.stop))
            alertView.addButton("なんでもない", target:self, selector:#selector(LeaveViewController.cancel))
            alertView.showWarning("おあずけを中止しますか？", subTitle: "\n中止すると、あずかり人にも通知されます。")
        }else{
            // 中断
            let alertView = SCLAlertView(appearance: self.appearance1!)
            alertView.addButton("おあずけ中断", target:self, selector:#selector(LeaveViewController.abort))
            alertView.addButton("なんでもない", target:self, selector:#selector(LeaveViewController.cancel))
            alertView.showWarning("おあずけを中断しますか？", subTitle: "\n中断する前に、ペットを引き取りましょう。")
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
        
        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveData!.id!)/runningFlag/": true,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/actualStartDate/": Date().description,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/updateAt/": String(time),
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/todoRoomIds/\(self.leaveData!.id!)/": true] as [String : Any]
        ref.updateChildValues(childUpdates)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        //TODO: ユーザーが思い出写真、コメントを投稿できるようにする（通知バッチ表示、当画面を開くとポップアップ表示）
        
        
        
        print("DEBUG_PRINT: LeaveViewController.excuted end")
    }
    func complete(){
        print("DEBUG_PRINT: LeaveViewController.complete start")
        
        var breederComment: String?
        var goods = self.userData?.goods
        var bads = self.userData?.bads
        
        // ユーザ評価
        let alertView = SCLAlertView(appearance: self.appearance1!)
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
        
        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveData!.id!)/runningFlag/": false,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/completeFlag/": true,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/breederComment/": breederComment ?? "[コメントはありません]",
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/actualEndDate/": Date().description,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/updateAt/": String(time),
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/goods/": goods ?? [],
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/bads/": bads ?? [],
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/todoRoomIds/\(self.leaveData!.id!)/": false,
                            "/\(Paths.UserPath)/\(self.leaveData!.breederId!)/todoRoomIds/\(self.leaveData!.id!)/": false] as [String : Any]
        ref.updateChildValues(childUpdates)
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.completeUpdateFIR end")
    }
    
    
    func stop(){
        print("DEBUG_PRINT: LeaveViewController.stop start")
        
        var breederComment: String?
        // 中止理由
        let alertView = SCLAlertView(appearance: self.appearance1!)
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
        
        var breederComment: String?
        var goods = self.userData?.goods
        var bads = self.userData?.bads
        // 中断理由
        let alertView = SCLAlertView(appearance: self.appearance1!)
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
        
        // leaveData,UserDataをupdate
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = FIRDatabase.database().reference()
        let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveData!.id!)/runningFlag/": false,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/abortFlag/": true,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/breederComment/": breederComment ?? "[コメントはありません]",
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/actualEndDate/": Date().description,
                            "/\(Paths.LeavePath)/\(self.leaveData!.id!)/updateAt/": String(time),
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/goods/": goods ?? [],
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/bads/": bads ?? [],
                            "/\(Paths.UserPath)/\(self.leaveData!.userId!)/todoRoomIds/\(self.leaveData!.id!)/": false,
                            "/\(Paths.UserPath)/\(self.leaveData!.breederId!)/todoRoomIds/\(self.leaveData!.id!)/": false] as [String : Any]
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
    
    
}

