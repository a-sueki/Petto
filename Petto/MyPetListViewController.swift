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
    var petDataArray: [PetData] = []
    var sortedPetDataArray: [PetData] = []
    
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
        // userのmessages[]を取得　→roomIdList
        if UserDefaults.standard.object(forKey: DefaultString.MyPets) != nil {
            
            for (key, _) in UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)!{
                self.petIdList.append(key)
                self.getDataSingleEvent(petId: key)
            }
        }else{
            //roomが0件の時は「メッセージ送受信はありません」を表示
            SVProgressHUD.showError(withStatus: "まだメッセージがありません")
        }
        
        print("DEBUG_PRINT: MyPetListViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: MyPetListViewController.viewWillAppear start")
        
        var petIdListAgain: [String] = []
        
        // userのmessages[]を取得　→roomIdList
        if UserDefaults.standard.object(forKey: DefaultString.MyPets) != nil {
            
            for (key, _) in UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)!{
                petIdListAgain.append(key)
            }
        }else{
            //roomが0件の時は「メッセージ送受信はありません」を表示
            SVProgressHUD.showError(withStatus: "まだペットを投稿していません")
        }
        
        // 比較用にsort
        let ascendingOldList : [String] = petIdList.sorted(by: {$0 < $1})
        let ascendingNewList : [String] = petIdListAgain.sorted(by: {$0 < $1})
        
        // roomIdListの内容が変わっていた場合（削除・追加）
        if ascendingOldList != ascendingNewList {
            print("DEBUG_PRINT: MyPetListViewController.viewWillAppear petIdListの内容が変更されました")
            // リストを初期化
            self.petDataArray.removeAll()
            self.sortedPetDataArray.removeAll()
            // リストを再取得・テーブルreloadData
            for key in ascendingNewList {
                self.getDataSingleEvent(petId: key)
            }
        }
        
        print("DEBUG_PRINT: MyPetListViewController.viewWillAppear end")
    }

    func getDataSingleEvent(petId: String) {
        print("DEBUG_PRINT: MyPetListViewController.getDataSingleEvent start")
        
        // petDataリストの取得
        let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MyPetListViewController.getDataSingleEvent .observeSingleEventイベントが発生しました。")
            if let _ = snapshot.value as? NSDictionary {
                let petData = PetData(snapshot: snapshot, myId: petId)
                self.petDataArray.append(petData)
                // 更新日で並び替え
                self.sortedPetDataArray = self.petDataArray.sorted(by: {
                    $0.createAt?.compare($1.createAt! as Date) == ComparisonResult.orderedDescending
                })
                // tableViewを再表示する
                self.tableView.reloadData()
                // HUDを消す
                SVProgressHUD.dismiss(withDelay: 1)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print("DEBUG_PRINT: MyPetListViewController.getDataSingleEvent end")
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
        if self.petIdList.count == self.sortedPetDataArray.count {
            cell.setData(petData: sortedPetDataArray[indexPath.row])
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
        let petData = sortedPetDataArray[indexPath!.row]
        
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        editViewController.petData = petData
        self.navigationController?.pushViewController(editViewController, animated: true)
        
        print("DEBUG_PRINT: MyPetListViewController.handleImageView end")
    }
}
