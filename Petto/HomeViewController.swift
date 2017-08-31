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

class HomeViewController: BaseViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var registerButton: UIButton!
    //var searchData = [String : Any]()
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
        
        // currentUserがnilならログインしていない
        if FIRAuth.auth()?.currentUser == nil {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                petData = []
                collectionView.reloadData()
                // オブザーバーを削除する
                FIRDatabase.database().reference().removeAllObservers()
                
                // FIRDatabaseのobserveEventが上記コードにより解除されたためfalseとする
                observing = false
            }
            
            // ログインしていないときの処理
            // viewDidAppear内でpresent()を呼び出しても表示されないためメソッドが終了してから呼ばれるようにする
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        }
        
        if FIRAuth.auth()?.currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = FIRDatabase.database().reference().child(Paths.PetPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: HomeViewController.viewWillAppear .childAddedイベントが発生しました。")
                    
                    // petDataクラスを生成して受け取ったデータを設定する
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        let petData = PetData(snapshot: snapshot, myId: uid)
                        self.petData.insert(petData, at: 0)
                        
                        // collectionViewを再表示する
                        self.collectionView.reloadData()
                    }
                })
                
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してcollectionViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
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
                    }
                })
                
                // 絞り込み条件を読み込む
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    // 要素が追加されたら再表示
                    let ref = FIRDatabase.database().reference().child(Paths.SearchPath).child(uid)
                    ref.observe(.value, with: { (snapshot) in
                        print("DEBUG_PRINT: HomeViewController.viewWillAppear .observeイベントが発生しました。")
                        if let _ = snapshot.value as? NSDictionary {
                            
                            self.searchData = SearchData(snapshot: snapshot, myId: uid)

                            // 絞り込み条件でフィルタリング
                                var index: Int = 0
                                for petInfo in self.petData {
                                    if let _ = self.searchData?.area ,petInfo.area != self.searchData?.area {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.kind ,petInfo.kind != self.searchData?.kind {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.category ,petInfo.category != self.searchData?.category {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.age ,petInfo.age != self.searchData?.age {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.isVaccinated ,petInfo.isVaccinated != self.searchData?.isVaccinated {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.isCastrated ,petInfo.isCastrated != self.searchData?.isCastrated {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.isAvailable ,petInfo.isAvailable != self.searchData?.isAvailable {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.environments ,petInfo.environments != (self.searchData?.environments)! {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.tools ,petInfo.tools != (self.searchData?.tools)! {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.startDate ,
                                        DateCommon.stringToDate(petInfo.startDate!) >= DateCommon.stringToDate((self.searchData?.startDate)!) {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.endDate ,
                                        DateCommon.stringToDate(petInfo.endDate!) <= DateCommon.stringToDate((self.searchData?.endDate)!) {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.minDays ,petInfo.minDays! >= (self.searchData?.minDays)! {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }else if let _ = self.searchData?.maxDays ,petInfo.maxDays! <= (self.searchData?.maxDays)! {
                                        index = self.petData.index(of: petInfo)!
                                        self.petData.remove(at: index)
                                    }
                                }
                                // TableViewの現在表示されているセルを更新する
                                self.collectionView.reloadData()
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

        // HUDで処理中を表示
        SVProgressHUD.show()

        // ユーザープロフィールが存在しない場合はクリック不可
        // Firebaseから登録済みデータを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: HomeViewController.registerButton .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    
                    // ペット登録に画面遷移
                    let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
                    self.navigationController?.pushViewController(editViewController, animated: true)
                    
                }else{
                    SVProgressHUD.showError(withStatus: "ペット登録にはプロフィール作成が必要です。")
                }
            })
            // FIRDatabaseのobserveEventが上記コードにより登録されたためtrueとする
            observing = true
        }

        // HUDを消す
        SVProgressHUD.dismiss()
        
        print("DEBUG_PRINT: HomeViewController.registerButton end")
    }
    
}
