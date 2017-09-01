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
import SVProgressHUD

class MyPetListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    var petIdList: [String] = []
    var userData: UserData?
    var petDataArray: [PetData] = []

    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MyPetListViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MyPetListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myPetListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // userのマイペットリストを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            // HUDで処理中を表示
            SVProgressHUD.show()
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: MyPetListViewController.viewDidLoad user.observeSingleEventイベントが発生しました。")
                self.userData = UserData(snapshot: snapshot, myId: uid)
                if self.userData?.myPets.count != 0 {
                    // user,petデータを取得
                    for (key, _) in (self.userData?.myPets)! {
                        self.petIdList.append(key)
                        self.getData(petId: key)
                    }
                    // tableViewを再表示する
                    self.tableView.reloadData()
                    // HUDを消す
                    SVProgressHUD.dismiss()
                }
                
            }) { (error) in
                // HUDを消す
                SVProgressHUD.dismiss()
                print(error.localizedDescription)
            }
            self.observing = true
        }else{
            print("DEBUG_PRINT: MyPetListViewController.viewDidLoad ユーザがログインしていません。")
            // ログインしていない場合
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                petIdList = []
                self.tableView.reloadData()
                // オブザーバーを削除する
                FIRDatabase.database().reference().removeAllObservers()
                // FIRDatabaseのobserveEventが上記コードにより解除されたためfalseとする
                observing = false
            }
            
            // ログイン画面に遷移
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        }
        print("DEBUG_PRINT: MyPetListViewController.viewDidLoad end")
    }
        
        func getData(petId: String) {
            print("DEBUG_PRINT: MyPetListViewController.getData start")
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            // petDataリストの取得
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: MyPetListViewController.getData pet.observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let petData = PetData(snapshot: snapshot, myId: petId)
                     self.petDataArray.append(petData)
                    // tableViewを再表示する
                    self.tableView.reloadData()
                    // HUDを消す
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                // HUDを消す
                SVProgressHUD.dismiss()
                print(error.localizedDescription)
            }
            
            print("DEBUG_PRINT: MyPetListViewController.getData end")
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.petIdList.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: MyPetListViewController.cellForRowAt start")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPetListCell", for: indexPath) as! MyPetListTableViewCell
        if self.petIdList.count == self.petDataArray.count {
            cell.setData(petData: petDataArray[indexPath.row])
            // セル内のボタンのアクションをソースコードで設定する
            cell.photoImageButton.addTarget(self, action:#selector(handleImageView(sender:event:)), for:  UIControlEvents.touchUpInside)
        }
        
        print("DEBUG_PRINT: MyPetListViewController.cellForRowAt end")
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
        print("DEBUG_PRINT: MyPetListViewController.handleImageView start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let petData = petDataArray[indexPath!.row]
        
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        editViewController.petData = petData
        self.navigationController?.pushViewController(editViewController, animated: true)

        print("DEBUG_PRINT: MyPetListViewController.handleImageView end")
    }
}
