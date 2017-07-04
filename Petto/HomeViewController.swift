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

class HomeViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    
    // サムネイル画像のタイトル
    let photos = ["dog1", "dog2","dog3","cat1","cat2","cat3","cat4","cat5","cat6","cat7"]
    let kinds = ["dog-lightgray", "dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray"]
    let sexs = ["male-lightgray", "male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray"]
    let areas = ["東京都", "東京都","神奈川県","神奈川県","神奈川県","東京都","東京都","神奈川県","静岡県","沖縄県"]
    let terms = ["期間：1~30 days", "期間：7 days","期間：3 days","期間：10 days","期間：1 day","期間：1 days","期間：29 days","期間：14~30 days","期間：14~30 days","期間：14~30 days"]
    
    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var postArray: [PostData] = []
    
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "homeCell")
        
        
        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(HomeViewController.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(HomeViewController.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(HomeViewController.onClick3))
        btn4 = UIBarButtonItem(image: UIImage(named: "mail"), style: .plain, target: self, action: #selector(HomeViewController.onClick4))
        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(HomeViewController.onClick5))

        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if FIRAuth.auth()?.currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = FIRDatabase.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // collectionViewを再表示する
                        self.collectionView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してcollectionViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのでデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewの現在表示されているセルを更新する
                        self.collectionView.reloadData()
                    }
                })
                
                // FIRDatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                collectionView.reloadData()
                // オブザーバーを削除する
                FIRDatabase.database().reference().removeAllObservers()
                
                // FIRDatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Cell はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: photos[(indexPath as NSIndexPath).row])
        
        // Tag番号を使ってImageViewのインスタンス生成
        let kindImageView = testCell.contentView.viewWithTag(2) as! UIImageView
        kindImageView.image = UIImage(named: kinds[(indexPath as NSIndexPath).row])

        // Tag番号を使ってImageViewのインスタンス生成
        let sexImageView = testCell.contentView.viewWithTag(3) as! UIImageView
        sexImageView.image = UIImage(named: sexs[(indexPath as NSIndexPath).row])

        // Tag番号を使ってLabelのインスタンス生成
        let arealabel = testCell.contentView.viewWithTag(4) as! UILabel
        arealabel.text = areas[(indexPath as NSIndexPath).row]

        // Tag番号を使ってLabelのインスタンス生成
        let termlabel = testCell.contentView.viewWithTag(5) as! UILabel
        termlabel.text = terms[(indexPath as NSIndexPath).row]
        
//        let likeButton = testCell.contentView.viewWithTag(6) as! UIButton
//        likeButton.image = UIImage(named: likes)

        return testCell
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
        return 10;
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onClick1() {
        self.slideMenuController()?.openLeft()
    }
    func onClick2() {
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    func onClick3() {
        let viewController3 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController3, animated: true)
    }
    func onClick4() {
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }

    
}
