//
//  MyPetListViewController.swift
//  Petto
//
//  Created by admin on 2017/07/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MyPetListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    var petDataArray: [PetData] = []

    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false

    // test用
    var petphotos = ["dog1", "dog2","dog3"]
    var petname = ["豆助1", "豆助2","豆助3"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MyPetListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myPetListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        // currentUserがnilならログインしていない
        if FIRAuth.auth()?.currentUser == nil {
            
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                petDataArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                FIRDatabase.database().reference().removeAllObservers()
                
                // FIRDatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
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
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // petDataクラスを生成して受け取ったデータを設定する
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        let petData = PetData(snapshot: snapshot, myId: uid)
                        self.petDataArray.insert(petData, at: 0)
                        
                        // tableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してcollectionViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        // petDataクラスを生成して受け取ったデータを設定する
                        let petData = PetData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for petInfo in self.petDataArray {
                            if petInfo.id == petData.id {
                                index = self.petDataArray.index(of: petInfo)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.petDataArray.remove(at: index)
                        
                        // 削除したところに更新済みのでデータを追加する
                        self.petDataArray.insert(petData, at: index)
                        
                        // TableViewの現在表示されているセルを更新する
                        self.tableView.reloadData()
                    }
                })
                
                // FIRDatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        }
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petDataArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
/*        // 再利用可能な cell を得る
        let testCell = tableView.dequeueReusableCell(withIdentifier: "myPetListCell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let userImageView = testCell.contentView.viewWithTag(1) as? UIImageView
        userImageView?.image = UIImage(named: petphotos[(indexPath as NSIndexPath).row])
        // Tag番号を使ってLabelのインスタンス生成
        let userNameLabel = testCell.contentView.viewWithTag(2) as? UILabel
        userNameLabel?.text = petname[(indexPath as NSIndexPath).row]
        return testCell
 */
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPetListCell", for: indexPath) as! MyPetListTableViewCell
        cell.setData(petData: petDataArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.photoImageButton.addTarget(self, action:#selector(handleImageView(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        return cell

    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    // ペットの写真がタップされたら編集画面に遷移
    func handleImageView(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let petData = petDataArray[indexPath!.row]
        
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        editViewController.petData = petData
        self.navigationController?.pushViewController(editViewController, animated: true)
    
    }
}
