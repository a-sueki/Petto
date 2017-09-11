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
    var petData: [PetData] = []
    
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    
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
        
        print("DEBUG_PRINT: HomeViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: HomeViewController.viewWillAppear start")
        
        
        if FIRAuth.auth()?.currentUser != nil {
            if self.observing == false {
                // HUDで処理中を表示
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = FIRDatabase.database().reference().child(Paths.PetPath)
                postsRef.queryLimited(toLast: 10).observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: HomeViewController.viewWillAppear .childAddedイベントが発生しました。")
                    
                    // petDataクラスを生成して受け取ったデータを設定する
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        let petData = PetData(snapshot: snapshot, myId: uid)
                        self.petData.insert(petData, at: 0)
                        
                        // collectionViewを再表示する
                        self.collectionView.reloadData()
                        // HUDを消す
                        SVProgressHUD.dismiss()
                    }
                })
                
                // HUDで処理中を表示
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してcollectionViewを再表示する
                postsRef.queryLimited(toLast: 10).observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: HomeViewController.viewWillAppear .childChangedイベントが発生しました。")
                    
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        // petDataクラスを生成して受け取ったデータを設定する
                        let petData = PetData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for petInfo in self.petData {
                            if petInfo.id == petData.id {
                                index = self.petData.index(of: petInfo)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.petData.remove(at: index)
                        // 削除したところに更新済みのでデータを追加する
                        self.petData.insert(petData, at: index)
                        // TableViewの現在表示されているセルを更新する
                        self.collectionView.reloadData()
                        // HUDを消す
                        SVProgressHUD.dismiss()
                    }
                })
                
                // 絞り込み条件を読み込む
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    // HUDで処理中を表示
                    SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                    // 要素が追加されたら再表示
                    let ref = FIRDatabase.database().reference().child(Paths.SearchPath).child(uid)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        print("DEBUG_PRINT: HomeViewController.viewWillAppear .observeSingleEventイベントが発生しました。")
                        if let _ = snapshot.value as? NSDictionary {
                            
                            self.searchData = SearchData(snapshot: snapshot, myId: uid)
                            
                            
                            // 絞り込み条件でフィルタリング
                            var index: Int = 0
                            for petInfo in self.petData {
                                if let _ = self.searchData?.area , self.searchData?.area != SearchString.unspecified ,petInfo.area != self.searchData?.area {
                                    print("1")
                                    print("\(String(describing: self.searchData?.area))と違うから\(String(describing: petInfo.area))は除外するお \(String(describing: petInfo.name))")
                                    index = self.petData.index(of: petInfo)!
                                    self.petData.remove(at: index)
                                }else if let _ = self.searchData?.kind , self.searchData?.kind != SearchString.unspecified ,petInfo.kind != self.searchData?.kind {
                                    print("2")
                                    print("\(String(describing: self.searchData?.kind))と違うから\(String(describing: petInfo.kind))は除外するお \(String(describing: petInfo.name))")
                                    index = self.petData.index(of: petInfo)!
                                    self.petData.remove(at: index)
                                }else if let _ = self.searchData?.sex , self.searchData?.sex != SearchString.unspecified ,petInfo.sex != self.searchData?.sex {
                                    print("3")
                                    print("\(String(describing: self.searchData?.sex))と違うから\(String(describing: petInfo.sex))は除外するお \(String(describing: petInfo.name))")
                                    index = self.petData.index(of: petInfo)!
                                    self.petData.remove(at: index)
                                }else if let _ = self.searchData?.isAvailable ,let _ = petInfo.isAvailable ,petInfo.isAvailable == self.searchData?.isAvailable {
                                    if self.searchData?.isAvailable == true {
                                        if let _ = self.searchData?.toolRentalAllowed , self.searchData?.toolRentalAllowed == true, petInfo.toolRentalAllowed != self.searchData?.toolRentalAllowed! {
                                            print("4")
                                            print("\(String(describing: self.searchData?.toolRentalAllowed))と違うから\(String(describing: petInfo.toolRentalAllowed))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.feedingFeePayable ,self.searchData?.feedingFeePayable == true, petInfo.feedingFeePayable != self.searchData?.feedingFeePayable! {
                                            print("5")
                                            print("\(String(describing: self.searchData?.feedingFeePayable))と違うから\(String(describing: petInfo.feedingFeePayable))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.startDate , let _ = self.searchData?.endDate {
                                            let searchStart = DateCommon.stringToDate((self.searchData?.startDate)!, dateFormat: DateCommon.dateFormat)
                                            let searchEnd = DateCommon.stringToDate((self.searchData?.endDate)!, dateFormat: DateCommon.dateFormat)
                                            let start = DateCommon.stringToDate((petInfo.startDate)!, dateFormat: DateCommon.dateFormat)
                                            let end = DateCommon.stringToDate((petInfo.endDate)!, dateFormat: DateCommon.dateFormat)
                                            // searchの開始日より、petの終了日が過去の場合
                                            if searchStart.compare(end) == ComparisonResult.orderedDescending {
                                                print("6")
                                                print("\(searchStart)>\(end)だから除外するお \(String(describing: petInfo.name))")
                                                index = self.petData.index(of: petInfo)!
                                                self.petData.remove(at: index)
                                                // searchの終了日より、petの開始日が未来の場合
                                            }else if searchEnd.compare(start) == ComparisonResult.orderedAscending{
                                                print("7")
                                                print("\(searchEnd)<\(start)だから除外するお \(String(describing: petInfo.name))")
                                                index = self.petData.index(of: petInfo)!
                                                self.petData.remove(at: index)
                                            }
                                        }else if let _ = self.searchData?.minDays, let _ = self.searchData?.maxDays {
                                            // search.min>pet.max、もしくはsearch.max<pet.minの場合
                                            if (self.searchData?.minDays)! > petInfo.maxDays! || (self.searchData?.maxDays)! < petInfo.minDays! {
                                                print("8")
                                                print("\(String(describing: self.searchData?.minDays))>\(String(describing: petInfo.maxDays))もしくは\(String(describing: self.searchData?.maxDays))＜\(String(describing: petInfo.minDays))だから除外するお \(String(describing: petInfo.name))")
                                                index = self.petData.index(of: petInfo)!
                                                self.petData.remove(at: index)
                                            }
                                        }
                                    }
                                }else if let _ = self.searchData?.enterDetails ,let _ = petInfo.enterDetails, petInfo.enterDetails == self.searchData?.enterDetails {
                                    if self.searchData?.enterDetails == true {
                                        if let _ = self.searchData?.age ,petInfo.age != self.searchData?.age! {
                                            print("9")
                                            print("\(String(describing: self.searchData?.age))と違うから\(String(describing: petInfo.age))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.size ,petInfo.size != self.searchData?.size! {
                                            print("10")
                                            print("\(String(describing: self.searchData?.size))と違うから\(String(describing: petInfo.size))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.color, !(self.searchData?.color.isEmpty)! {
                                            var matchCount = 0
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
                                                print("11")
                                                print("\(String(describing: self.searchData?.color))に\(String(describing: petInfo.color))は含まれてないから除外するお \(String(describing: petInfo.name))")
                                                index = self.petData.index(of: petInfo)!
                                                self.petData.remove(at: index)
                                            }
                                        }else if let _ = self.searchData?.category ,petInfo.category != self.searchData?.category! {
                                            print("12")
                                            print("\(String(describing: self.searchData?.category))と違うから\(String(describing: petInfo.category))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }
                                    }
                                }else if let _ = self.searchData?.specifyConditions {
                                    print("aaaaaaa")
                                    if self.searchData?.specifyConditions == true {
                                        if let _ = self.searchData?.isVaccinated ,self.searchData?.isVaccinated == true ,petInfo.isVaccinated != self.searchData?.isVaccinated! {
                                            print("13")
                                            print("\(String(describing: self.searchData?.isVaccinated))と違うから\(String(describing: petInfo.isVaccinated))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.isCastrated ,self.searchData?.isCastrated == true ,petInfo.isCastrated != self.searchData?.isCastrated! {
                                            print("14")
                                            print("\(String(describing: self.searchData?.isCastrated))と違うから\(String(describing: petInfo.isCastrated))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.wanted ,self.searchData?.wanted == true, petInfo.wanted != self.searchData?.wanted! {
                                            print("15")
                                            print("\(String(describing: self.searchData?.wanted))と違うから\(String(describing: petInfo.wanted))は除外するお \(String(describing: petInfo.name))")
                                            index = self.petData.index(of: petInfo)!
                                            self.petData.remove(at: index)
                                        }else if let _ = self.searchData?.userNgs, !(self.searchData?.userNgs.isEmpty)! {
                                            var matchCount = 0
                                            for (skey,sValue) in (self.searchData?.userNgs)! {
                                                for (key,value) in petInfo.userNgs {
                                                    if skey == key {
                                                        print("\(key)")
                                                        print("\(sValue)")
                                                        print("\(value)")
                                                        if sValue == true && sValue == value {
                                                            matchCount = matchCount + 1
                                                        }
                                                    }
                                                }
                                            }
                                            if matchCount != 0 {
                                                print("16")
                                                print("\(String(describing: self.searchData?.userNgs))と\(String(describing: petInfo.userNgs))に一致項目があるから除外するお \(String(describing: petInfo.name))")
                                                index = self.petData.index(of: petInfo)!
                                                self.petData.remove(at: index)
                                            }
                                        }
                                    }
                                }
                            }
                            // TableViewの現在表示されているセルを更新する
                            self.collectionView.reloadData()
                            if snapshot.value != nil && self.petData.count == 0 {
                                SVProgressHUD.showError(withStatus: "該当するペットがいません。検索条件を変更してください")
                            }
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
                
                // FIRDatabaseのobserveEventが上記コードにより登録されたためtrueとする
                observing = true
            }
        }
        
        print("DEBUG_PRINT: HomeViewController.viewWillAppear end")
    }
    
    // 検索条件が指定されているかどうか？
/*    func isConditionSpecified() -> Bool {
        if .... {
            return true
        }
        return false
    }
*/    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        cell.setPetData(petData: petData[indexPath.row])
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleLikeButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.toDetailButton.addTarget(self, action: #selector(handleToDetailButton(sender:event:)), for: UIControlEvents.touchUpInside)
        return cell
        
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2-2
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize*1.4141)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return petData.count
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    func handleLikeButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: HomeViewController.handleLikeButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let petData = self.petData[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if petData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in petData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = petData.likes.index(of: likeId)!
                        break
                    }
                }
                petData.likes.remove(at: index)
            } else {
                petData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = FIRDatabase.database().reference().child(Paths.PetPath).child(petData.id!)
            let likes = ["likes": petData.likes]
            postRef.updateChildValues(likes)
            
        }
        print("DEBUG_PRINT: HomeViewController.handleLikeButton end")
    }
    
    func handleToDetailButton(sender: UIButton, event: UIEvent) {
        print("DEBUG_PRINT: HomeViewController.handleToDetailButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let petData = self.petData[indexPath!.row]
        // PetDetailに画面遷移
        let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
        petDetailViewController.petData = petData
        self.navigationController?.pushViewController(petDetailViewController, animated: true)
        
        
        print("DEBUG_PRINT: HomeViewController.handleToDetailButton end")
    }
    
    @IBAction func registerButton(_ sender: Any) {
        print("DEBUG_PRINT: HomeViewController.registerButton start")
        
        if !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            // ペット登録に画面遷移
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
            self.navigationController?.pushViewController(editViewController, animated: true)
        }else{
            // ユーザープロフィールが存在しない場合はクリック不可
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "プロフィールを登録してください")
            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            self.navigationController?.pushViewController(userViewController, animated: true)
        }
        // HUDを消す
        SVProgressHUD.dismiss(withDelay: 1)
        
        print("DEBUG_PRINT: HomeViewController.registerButton end")
    }
}
