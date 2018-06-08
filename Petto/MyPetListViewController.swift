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
    var petDataArray: [PetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MyPetListViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MyPetListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myPetListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        print("DEBUG_PRINT: MyPetListViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: MyPetListViewController.viewWillAppear start")

        if UserDefaults.standard.dictionary(forKey: DefaultString.MyPets) == nil || UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)?.count == 0 {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "まだペットの投稿がありません")
        }
        self.petDataArray.removeAll()
        self.read()
        
        print("DEBUG_PRINT: MyPetListViewController.viewWillAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: MyPetListViewController.viewWillDisappear start")
        
        if UserDefaults.standard.dictionary(forKey: DefaultString.MyPets) != nil, !UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)!.isEmpty {
            for (pid,_) in UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)! {
                let ref = Database.database().reference().child(Paths.PetPath).child(pid)
                ref.removeAllObservers()
            }
        }
        
        print("DEBUG_PRINT: MyPetListViewController.viewWillDisappear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT: MyPetListViewController.numberOfRowsInSection start")
        print("DEBUG_PRINT: MyPetListViewController.numberOfRowsInSection end")
        return petDataArray.count
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: MyPetListViewController.didSelectRowAt start")
        
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print("DEBUG_PRINT: MyPetListViewController.didSelectRowAt end")
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        print("DEBUG_PRINT: MyPetListViewController.editingStyleForRowAt start")
        print("DEBUG_PRINT: MyPetListViewController.editingStyleForRowAt end")
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        print("DEBUG_PRINT: MyPetListViewController.estimatedHeightForRowAt start")
        print("DEBUG_PRINT: MyPetListViewController.estimatedHeightForRowAt end")
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    //返すセルを決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: MyPetListViewController.cellForRowAt start")
        
        //xibとカスタムクラスで作成したCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPetListCell", for: indexPath) as! MyPetListTableViewCell
        // セル内のボタンのアクションをソースコードで設定する
        cell.photoImageButton.addTarget(self, action:#selector(handleImageView(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        cell.setData(petData: self.petDataArray[indexPath.row])
        
        if self.petDataArray[indexPath.row].isAvailable! {
            let endDate = DateCommon.stringToDate(self.petDataArray[indexPath.row].endDate!, dateFormat: DateCommon.dateFormat)
            if endDate.compare(Date()) == ComparisonResult.orderedAscending {
                // 期間外
                cell.isAvailableLabel.isHidden = true
            }
            if self.petDataArray[indexPath.row].runningFlag != nil ,  self.petDataArray[indexPath.row].runningFlag! {
                // おあずけ中
                cell.outNowLabel.isHidden = false
            }else{
                // おあずけ中
                cell.outNowLabel.isHidden = true
            }
        }else{
            cell.isAvailableLabel.isHidden = true
            cell.outNowLabel.isHidden = true
            cell.endDateLabel.isHidden = true
        }
        
        print("DEBUG_PRINT: MyPetListViewController.cellForRowAt end")
        return cell
    }
  
    func read() {
        print("DEBUG_PRINT: MyPetListViewController.read start")
        // userのmyPetsを取得
        if UserDefaults.standard.dictionary(forKey: DefaultString.MyPets) != nil && !(UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)?.isEmpty)! {
            // petリストの取得
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            for (pid,_) in UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)! {
                let ref = Database.database().reference().child(Paths.PetPath).child(pid).queryOrderedByKey()
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print("DEBUG_PRINT: MyPetListViewController.read .observeSingleEventイベントが発生しました。")
                    if let _ = snapshot.value as? NSDictionary {
                        // roomを取得
                        let petDats = PetData(snapshot: snapshot, myId: pid)
                        self.petDataArray.append(petDats)
                        
                        // 更新日で並び替え
                        self.petDataArray = self.petDataArray.sorted(by: {
                            $0.updateAt?.compare($1.updateAt! as Date) == ComparisonResult.orderedDescending
                        })
                    }
                    
                    // tableViewを再表示する
                    if UserDefaults.standard.dictionary(forKey: DefaultString.MyPets)!.count == self.petDataArray.count {
                        DispatchQueue.main.async {
                            print("DEBUG_PRINT: MyPetListViewController.read [DispatchQueue.main.async]")
                            self.tableView.reloadData()
                            SVProgressHUD.dismiss()
                        }
                    }
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
                }
            }
        }
        print("DEBUG_PRINT: MyPetListViewController.read end")
    }
    
    // ペットの写真がタップされたら編集画面に遷移
    @objc func handleImageView(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: MyPetListViewController.handleImageView start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let petData = self.petDataArray[indexPath!.row]
        
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        editViewController.petData = petData
        self.navigationController?.pushViewController(editViewController, animated: true)
        
        print("DEBUG_PRINT: MyPetListViewController.handleImageView end")
    }
}
