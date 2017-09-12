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
        
        print("DEBUG_PRINT: HomeViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: HomeViewController.viewWillAppear start")
        
        self.petDataArray.removeAll()
        self.read()
        if UserDefaults.standard.string(forKey: DefaultString.Uid) != nil && UserDefaults.standard.bool(forKey: DefaultString.WithSearch) {
            self.refreshBysearch()
        }
        
        print("DEBUG_PRINT: HomeViewController.viewWillAppear end")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("DEBUG_PRINT: HomeViewController.viewDidDisappear start")
        
//        let ref = FIRDatabase.database().reference().child(Paths.PetPath)
//        ref.removeAllObservers()
        
        if UserDefaults.standard.string(forKey: DefaultString.Uid) != nil && UserDefaults.standard.bool(forKey: DefaultString.WithSearch) {
            let ref = FIRDatabase.database().reference().child(Paths.SearchPath).child(UserDefaults.standard.string(forKey: DefaultString.Uid)!)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: HomeViewController.viewDidDisappear end")
    }
    
    func read(){
        print("DEBUG_PRINT: HomeViewController.read start")
        
        let ref = FIRDatabase.database().reference().child(Paths.PetPath)
        
        // HUDで処理中を表示
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        ref.queryOrderedByKey().queryLimited(toLast: 10).observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: HomeViewController.read .childAddedイベントが発生しました。")
            
            if let _ = snapshot.value {
                // petDataクラスを生成して受け取ったデータを設定する
                let petData = PetData(snapshot: snapshot, myId: snapshot.key)
                self.petDataArray.insert(petData, at: 0)
                
                self.reload(petDataArray: self.petDataArray)
            }
            DispatchQueue.main.async {
                print("DEBUG_PRINT: HomeViewController.read [DispatchQueue.main.async]")
                SVProgressHUD.dismiss()
            }
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
        }
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してcollectionViewを再表示する
        // HUDで処理中を表示
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        ref.queryOrderedByKey().queryLimited(toLast: 10).observe(.childChanged, with: { snapshot in
            print("DEBUG_PRINT: HomeViewController.read .childChangedイベントが発生しました。")
            
            if let _ = snapshot.value {
                // petDataクラスを生成して受け取ったデータを設定する
                let petData = PetData(snapshot: snapshot, myId: snapshot.key)
                
                // 保持している配列からidが同じものを探す
                var index: Int = 0
                for row in self.petDataArray {
                    if row.id == petData.id {
                        index = self.petDataArray.index(of: row)!
                        break
                    }
                }
                // 差し替えるため一度削除する
                self.petDataArray.remove(at: index)
                // 削除したところに更新済みのでデータを追加する
                self.petDataArray.insert(petData, at: index)
                
                self.reload(petDataArray: self.petDataArray)
            }
            DispatchQueue.main.async {
                print("DEBUG_PRINT: HomeViewController.read [DispatchQueue.main.async]")
                SVProgressHUD.dismiss()
            }
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
        }
        
        print("DEBUG_PRINT: HomeViewController.read end")
    }

    func refreshBysearch(){
        print("DEBUG_PRINT: HomeViewController.refreshBysearch start")
        print("DEBUG_PRINT: HomeViewController.refreshBysearch end")
    }
    
    func reload(petDataArray: [PetData]) {
        print("DEBUG_PRINT: HomeViewController.reload start")
        
        // collectionViewを再表示する
        self.collectionView.reloadData()
        
        print("DEBUG_PRINT: HomeViewController.reload end")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        cell.setPetData(petData: petDataArray[indexPath.row])
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
        return petDataArray.count
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
        let petData = self.petDataArray[indexPath!.row]
        
        //TODO: ref.runTransactionBlockに修正
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
        let petData = self.petDataArray[indexPath!.row]
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
