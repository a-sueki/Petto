//
//  HomeViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import UserNotifications

class HomeViewController: BaseViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var registerButton: UIButton!
    var searchOnFlag :Bool?
    var searchData: SearchData?
    var petDataArray: [PetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: HomeViewController.viewDidLoad start")
        
        //ペット登録ボタンを丸くする
        registerButton.layer.cornerRadius = 75.0
        registerButton.layer.masksToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "homeCell")
        
        self.petDataArray.removeAll()
        self.read()
        if UserDefaults.standard.string(forKey: DefaultString.WithSearch) != nil {
            self.refreshBysearch()
        }
        
        print("DEBUG_PRINT: HomeViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: HomeViewController.viewWillAppear start")
        
        
        print("DEBUG_PRINT: HomeViewController.viewWillAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DEBUG_PRINT: HomeViewController.viewWillDisappear start")
        
        if UserDefaults.standard.string(forKey: DefaultString.Uid) != nil && UserDefaults.standard.string(forKey: DefaultString.WithSearch) != nil {
            let ref = FIRDatabase.database().reference().child(Paths.SearchPath).child(UserDefaults.standard.string(forKey: DefaultString.WithSearch)!)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: HomeViewController.viewWillDisappear end")
    }
    
    func read(){
        print("DEBUG_PRINT: HomeViewController.read start")
        
        let ref = FIRDatabase.database().reference().child(Paths.PetPath)
        
        // HUDで処理中を表示
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        ref.queryOrderedByKey().queryLimited(toLast: 100).observe(.value, with: { snapshot in
            print("DEBUG_PRINT: HomeViewController.read .childAddedイベントが発生しました。")
            
            // petDataクラスを生成して受け取ったデータを設定する
            if let _ = snapshot.value {
                self.petDataArray.removeAll()
                for childSnap in snapshot.children {
                    
                    let petData = PetData(snapshot: childSnap as! FIRDataSnapshot , myId: (childSnap as! FIRDataSnapshot).key)
                    self.petDataArray.insert(petData, at: 0)
                    
                    DispatchQueue.main.async {
                        print("DEBUG_PRINT: HomeViewController.read [DispatchQueue.main.async]")
                        // collectionViewを再表示する
                        self.collectionView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
        }
        
        print("DEBUG_PRINT: HomeViewController.read end")
    }
    
    func refreshBysearch(){
        print("DEBUG_PRINT: HomeViewController.refreshBysearch start")
        
        // 絞り込み条件を読み込む
        if let key = UserDefaults.standard.string(forKey: DefaultString.WithSearch) {
            // HUDで処理中を表示
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.SearchPath).child(key)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: HomeViewController.viewWillAppear .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    
                    self.searchData = SearchData(snapshot: snapshot, myId: key)
                    
                    // 絞り込み条件でフィルタリング
                    var index: Int = 0
                    for petInfo in self.petDataArray {
                        if let _ = self.searchData?.area , self.searchData?.area != SearchString.unspecified ,petInfo.area != self.searchData?.area {
                            print("1")
                            print("\(String(describing: self.searchData?.area))と違うから\(String(describing: petInfo.area))は除外するお \(String(describing: petInfo.name))")
                            index = self.petDataArray.index(of: petInfo)!
                            self.petDataArray.remove(at: index)
                            continue
                        }
                        if (self.searchData?.lev11)! {
                            if let _ = self.searchData?.kind , self.searchData?.kind != SearchString.unspecified ,petInfo.kind != self.searchData?.kind {
                                print("2")
                                print("\(String(describing: self.searchData?.kind))と違うから\(String(describing: petInfo.kind))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.age ,let _ = petInfo.age, petInfo.age != self.searchData?.age! {
                                print("3")
                                print("\(String(describing: self.searchData?.age))と違うから\(String(describing: petInfo.age))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.size ,let _ = petInfo.size, petInfo.size != self.searchData?.size! {
                                print("4")
                                print("\(String(describing: self.searchData?.size))と違うから\(String(describing: petInfo.size))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.sex , self.searchData?.sex != SearchString.unspecified ,petInfo.sex != self.searchData?.sex {
                                print("5")
                                print("\(String(describing: self.searchData?.sex))と違うから\(String(describing: petInfo.sex))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.color, !(self.searchData?.color.isEmpty)! {
                                var searchCount = 0
                                var matchCount = 0
                                for (_,sValue) in (self.searchData?.color)! {
                                    if sValue == true{
                                        searchCount = searchCount + 1
                                    }
                                }
                                if searchCount != 0 {
                                    for (skey,sValue) in (self.searchData?.color)! {
                                        for (key,value) in petInfo.color {
                                            if skey == key {
                                                if sValue == true && sValue == value {
                                                    matchCount = matchCount + 1
                                                }
                                            }
                                        }
                                    }
                                    if matchCount == 0 {
                                        print("6")
                                        print("\(String(describing: self.searchData?.color))に\(String(describing: petInfo.color))は含まれてないから除外するお \(String(describing: petInfo.name))")
                                        index = self.petDataArray.index(of: petInfo)!
                                        self.petDataArray.remove(at: index)
                                        continue
                                    }
                                }
                            }
                        }
                        if (self.searchData?.lev21)! {
                            if let _ = self.searchData?.isAvailable , (self.searchData?.isAvailable)! ,let _ = petInfo.isAvailable, !(petInfo.isAvailable! == (self.searchData?.isAvailable)!) {
                                print("7")
                                print("\(String(describing: self.searchData?.isAvailable))と違うから\(String(describing: petInfo.isAvailable))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.toolRentalAllowed ,(self.searchData?.toolRentalAllowed)! ,let _ = petInfo.toolRentalAllowed, !(petInfo.toolRentalAllowed! == (self.searchData?.toolRentalAllowed)!) {
                                print("8")
                                print("\(String(describing: self.searchData?.toolRentalAllowed))と違うから\(String(describing: petInfo.toolRentalAllowed))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.feedingFeePayable ,(self.searchData?.feedingFeePayable)!, let _ = petInfo.feedingFeePayable, !(petInfo.feedingFeePayable! == (self.searchData?.feedingFeePayable)!) {
                                print("9")
                                print("\(String(describing: self.searchData?.feedingFeePayable))と違うから\(String(describing: petInfo.feedingFeePayable))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.startDate , let _ = self.searchData?.endDate, let _ = petInfo.startDate , let _ = petInfo.endDate {
                                let searchStart = DateCommon.stringToDate((self.searchData?.startDate)!, dateFormat: DateCommon.dateFormat)
                                let searchEnd = DateCommon.stringToDate((self.searchData?.endDate)!, dateFormat: DateCommon.dateFormat)
                                let start = DateCommon.stringToDate((petInfo.startDate)!, dateFormat: DateCommon.dateFormat)
                                let end = DateCommon.stringToDate((petInfo.endDate)!, dateFormat: DateCommon.dateFormat)
                                // searchの開始日より、petの終了日が過去の場合
                                if searchStart.compare(end) == ComparisonResult.orderedDescending {
                                    print("10")
                                    print("\(searchStart)>\(end)だから除外するお \(String(describing: petInfo.name))")
                                    index = self.petDataArray.index(of: petInfo)!
                                    self.petDataArray.remove(at: index)
                                    continue
                                    // searchの終了日より、petの開始日が未来の場合
                                }else if searchEnd.compare(start) == ComparisonResult.orderedAscending{
                                    print("11")
                                    print("\(searchEnd)<\(start)だから除外するお \(String(describing: petInfo.name))")
                                    index = self.petDataArray.index(of: petInfo)!
                                    self.petDataArray.remove(at: index)
                                    continue
                                }
                            }else if let _ = self.searchData?.minDays, let _ = self.searchData?.maxDays,let _ = petInfo.minDays, let _ = petInfo.maxDays  {
                                // search.min>pet.max、もしくはsearch.max<pet.minの場合
                                if (self.searchData?.minDays)! > petInfo.maxDays! || (self.searchData?.maxDays)! < petInfo.minDays! {
                                    print("12")
                                    print("\(String(describing: self.searchData?.minDays))>\(String(describing: petInfo.maxDays))もしくは\(String(describing: self.searchData?.maxDays))＜\(String(describing: petInfo.minDays))だから除外するお \(String(describing: petInfo.name))")
                                    index = self.petDataArray.index(of: petInfo)!
                                    self.petDataArray.remove(at: index)
                                    continue
                                }
                            }
                        }
                        if (self.searchData?.lev31)! {
                            if let _ = self.searchData?.isVaccinated ,(self.searchData?.isVaccinated)!, let _ = petInfo.isVaccinated, !(petInfo.isVaccinated! == (self.searchData?.isVaccinated)!) {
                                print("13")
                                print("\(String(describing: self.searchData?.isVaccinated))と違うから\(String(describing: petInfo.isVaccinated))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.isCastrated ,(self.searchData?.isCastrated)!, let _ = petInfo.isCastrated, !(petInfo.isCastrated! == (self.searchData?.isCastrated)!) {
                                print("14")
                                print("\(String(describing: self.searchData?.isCastrated))と違うから\(String(describing: petInfo.isCastrated))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.wanted ,(self.searchData?.wanted)!, let _ = petInfo.wanted, !(petInfo.wanted! == (self.searchData?.wanted)!) {
                                print("15")
                                print("\(String(describing: self.searchData?.wanted))と違うから\(String(describing: petInfo.wanted))は除外するお \(String(describing: petInfo.name))")
                                index = self.petDataArray.index(of: petInfo)!
                                self.petDataArray.remove(at: index)
                                continue
                            }else if let _ = self.searchData?.userNgs, !(self.searchData?.userNgs.isEmpty)! {
                                var searchCount = 0
                                var matchCount = 0
                                for (_,sValue) in (self.searchData?.userNgs)! {
                                    if sValue == true{
                                        searchCount = searchCount + 1
                                    }
                                }
                                if searchCount != 0 {
                                    for (skey,sValue) in (self.searchData?.userNgs)! {
                                        for (key,value) in petInfo.userNgs {
                                            if skey == key {
                                                if sValue == true && sValue == value {
                                                    matchCount = matchCount + 1
                                                }
                                            }
                                        }
                                    }
                                    if matchCount != 0 {
                                        print("16")
                                        print("\(String(describing: self.searchData?.userNgs))に\(String(describing: petInfo.userNgs))は含まれてないから除外するお \(String(describing: petInfo.name))")
                                        index = self.petDataArray.index(of: petInfo)!
                                        self.petDataArray.remove(at: index)
                                        continue
                                    }
                                }
                            }
                       }
                    }
                    // TableViewの現在表示されているセルを更新する
                    self.collectionView.reloadData()
                    if snapshot.value != nil && self.petDataArray.count == 0 {
                        SVProgressHUD.showError(withStatus: "該当するペットがいません。検索条件を変更してください")
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        print("DEBUG_PRINT: HomeViewController.refreshBysearch end")
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        print("DEBUG_PRINT: HomeViewController.cellForItemAt start")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        cell.setPetData(petData: petDataArray[indexPath.row])
        // セル内のボタンのアクションをソースコードで設定する
        cell.toDetailButton.addTarget(self, action: #selector(handleToDetailButton(sender:event:)), for: UIControlEvents.touchUpInside)
        
        print("DEBUG_PRINT: HomeViewController.cellForItemAt end")
        return cell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2 - 1
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize*1.4141)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return petDataArray.count
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleToDetailButton(sender: UIButton, event: UIEvent) {
        print("DEBUG_PRINT: HomeViewController.handleToDetailButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let petData = self.petDataArray[indexPath!.row]
        // PetDetailに画面遷移
        let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
        petDetailViewController.petData = petData
        self.navigationController?.pushViewController(petDetailViewController, animated: true)
        
        
        print("DEBUG_PRINT: HomeViewController.handleToDetailButton end")
    }
    
    @IBAction func registerButton(_ sender: Any) {
        print("DEBUG_PRINT: HomeViewController.registerButton start")
        
        // ユーザープロフィールが未作成の場合
        if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            self.navigationController?.pushViewController(userViewController, animated: true)
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "ペットの投稿にはプロフィール作成が必要です")
            SVProgressHUD.dismiss(withDelay: 3)
        }else if FIRAuth.auth()?.currentUser == nil {
            let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! AccountViewController
            let navigationController = UINavigationController(rootViewController: accountViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "先にログインして下さい")
            SVProgressHUD.dismiss(withDelay: 3)
        }else{
            // ペット登録に画面遷移
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
        
        print("DEBUG_PRINT: HomeViewController.registerButton end")
    }
    
    
    
}
