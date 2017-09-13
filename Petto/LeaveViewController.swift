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

class LeaveViewController: BaseViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    var conditionArray = [String]()
    var leaveData: LeaveData?
    var userData: UserData?
    var petData: PetData?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var conditionsCollectionView: UICollectionView!
    @IBOutlet weak var excuteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
        
        // 自分があずかり人の場合
        if self.leaveData?.userId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            self.termLabel.text = "あずかり期間"
            self.excuteButton.titleLabel?.text = "あずかりを開始する！"
        }else{
            self.termLabel.text = "おあずけ期間"
            self.excuteButton.titleLabel?.text = "おあずけを開始する！"
        }
        self.userImageView.image = self.leaveData?.userImage
        self.petImageView.image = self.leaveData?.petImage
        self.startDateLabel.text = DateCommon.displayDate(stringDate: (self.leaveData?.startDate)!)
        self.endDateLabel.text = DateCommon.displayDate(stringDate: (self.leaveData?.endDate)!)
        
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
    
}

