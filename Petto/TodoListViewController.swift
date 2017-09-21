//
//  TodoListViewController.swift
//  Petto
//
//  Created by admin on 2017/09/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class TodoListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var leaveDataArray: [LeaveData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: TodoListViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)

        let nib = UINib(nibName: "TodoListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "todoListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        print("DEBUG_PRINT: TodoListViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: TodoListViewController.viewWillAppear start")

        super.helper.setupNavigationBar()
        if UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds) == nil || UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)?.count == 0 {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "ペットのおあずけ/おあずかり予定はありません")
        }
        self.leaveDataArray.removeAll()
        self.read()
        
        print("DEBUG_PRINT: TodoListViewController.viewWillAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: TodoListViewController.viewWillDisappear start")
        
        if UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds) != nil && (UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)?.isEmpty)! {
            for (leaveId,_) in UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)! {
                let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(leaveId)
                ref.removeAllObservers()
            }
        }
        
/*        for leaves in self.leaveDataArray {
            if let userId = leaves.userId {
                let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(userId)
                ref.removeAllObservers()
            }
            if let petId = leaves.petId {
                let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
                ref.removeAllObservers()
            }
        }
*/
        print("DEBUG_PRINT: TodoListViewController.viewWillDisappear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT: TodoListViewController.numberOfRowsInSection start")
        print("DEBUG_PRINT: TodoListViewController.numberOfRowsInSection end")
        return leaveDataArray.count
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: TodoListViewController.didSelectRowAt start")
        
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print("DEBUG_PRINT: TodoListViewController.didSelectRowAt end")
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        print("DEBUG_PRINT: TodoListViewController.editingStyleForRowAt start")
        print("DEBUG_PRINT: TodoListViewController.editingStyleForRowAt end")
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        print("DEBUG_PRINT: TodoListViewController.estimatedHeightForRowAt start")
        print("DEBUG_PRINT: TodoListViewController.estimatedHeightForRowAt end")
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    //返すセルを決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: TodoListViewController.cellForRowAt start")
        
        //xibとカスタムクラスで作成したCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoListCell", for: indexPath) as! TodoListTableViewCell
        // セル内のボタンのアクションをソースコードで設定する
        cell.leaveInfoButton.addTarget(self, action:#selector(handleLeaveInfoButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.userDetailButton.addTarget(self, action:#selector(handleUserDetailButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.petDetailButton.addTarget(self, action:#selector(handlePetDetailButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        
        cell.setData(leaveData: self.leaveDataArray[indexPath.row])
        
        if self.leaveDataArray[indexPath.row].breederId != UserDefaults.standard.string(forKey: DefaultString.Uid) {
            print("DEBUG_PRINT: TodoListViewController.cellForRowAt a")
            // あずかり人の場合
            // 未実施
            if self.leaveDataArray[indexPath.row].acceptFlag == true && self.leaveDataArray[indexPath.row].runningFlag == false &&
                self.leaveDataArray[indexPath.row].stopFlag == false && self.leaveDataArray[indexPath.row].abortFlag == false && self.leaveDataArray[indexPath.row].completeFlag == false{
                print("DEBUG_PRINT: TodoListViewController.cellForRowAt b")
                // 開始日 < 今日
                if DateCommon.stringToDate(self.leaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
                    print("DEBUG_PRINT: TodoListViewController.cellForRowAt c")
                    print(DateCommon.stringToDate(self.leaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat))
                    print(Date())
                    // 開始日を過ぎているのに未実施の場合、セルの背景を変えて「過ぎている」ラベルを表示
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = false
                    cell.isBreederLabel.isHidden = true
                }else{
                    print(DateCommon.stringToDate(self.leaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat))
                    print(Date())
                    print("DEBUG_PRINT: TodoListViewController.cellForRowAt d")
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = true
                    cell.isBreederLabel.isHidden = true
                }
                // 実施中
            } else if self.leaveDataArray[indexPath.row].runningFlag == true && self.leaveDataArray[indexPath.row].abortFlag == false && self.leaveDataArray[indexPath.row].completeFlag == false {
                // 終了日 < 今日
                if DateCommon.stringToDate(self.leaveDataArray[indexPath.row].endDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
                    // 終了日を過ぎているのに実施中の場合、セルの背景を変えて「過ぎている」ラベルを表示
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    cell.willDoLabel.backgroundColor = UIColor(red:0.196, green:0.804, blue:0.196, alpha:1.0)
                    cell.willDoLabel.text = "実施中"
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = false
                    cell.isBreederLabel.isHidden = true
                }else{
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    cell.willDoLabel.backgroundColor = UIColor(red:0.196, green:0.804, blue:0.196, alpha:1.0)
                    cell.willDoLabel.text = "実施中"
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = true
                    cell.isBreederLabel.isHidden = true
                }
                // 中止
            } else if self.leaveDataArray[indexPath.row].stopFlag == true {
                cell.willDoLabel.text = "中止"
                cell.willDoLabel.backgroundColor = UIColor.gray
                cell.willDoLabel.isHidden = false
                cell.overdueLabel.isHidden = true
                cell.isBreederLabel.isHidden = true
                // 中断
            } else if self.leaveDataArray[indexPath.row].abortFlag == true {
                cell.willDoLabel.text = "中断"
                cell.willDoLabel.backgroundColor = UIColor.gray
                cell.willDoLabel.isHidden = false
                cell.overdueLabel.isHidden = true
                cell.isBreederLabel.isHidden = true
                // 完了
            } else if self.leaveDataArray[indexPath.row].completeFlag == true {
                cell.willDoLabel.text = "完了"
                cell.willDoLabel.backgroundColor = UIColor.gray
                cell.willDoLabel.isHidden = false
                cell.overdueLabel.isHidden = true
                cell.isBreederLabel.isHidden = true
            }
        }else{
            // ブリーダーの場合
            // 未実施
            if self.leaveDataArray[indexPath.row].acceptFlag == true && self.leaveDataArray[indexPath.row].runningFlag == false &&
                self.leaveDataArray[indexPath.row].stopFlag == false && self.leaveDataArray[indexPath.row].abortFlag == false && self.leaveDataArray[indexPath.row].completeFlag == false{
                print("DEBUG_PRINT: TodoListViewController.cellForRowAt b")
                // 開始日 < 今日
                if DateCommon.stringToDate(self.leaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
                    print("DEBUG_PRINT: TodoListViewController.cellForRowAt c")
                    print(DateCommon.stringToDate(self.leaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat))
                    print(Date())
                    // 開始日を過ぎているのに未実施の場合、セルの背景を変えて「過ぎている」ラベルを表示
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = false
                    cell.isBreederLabel.isHidden = false
                }else{
                    print(DateCommon.stringToDate(self.leaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat))
                    print(Date())
                    print("DEBUG_PRINT: TodoListViewController.cellForRowAt d")
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = true
                    cell.isBreederLabel.isHidden = false
                }
                // 実施中
            } else if self.leaveDataArray[indexPath.row].runningFlag == true && self.leaveDataArray[indexPath.row].abortFlag == false && self.leaveDataArray[indexPath.row].completeFlag == false {
                // 終了日 < 今日
                if DateCommon.stringToDate(self.leaveDataArray[indexPath.row].endDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
                    // 終了日を過ぎているのに実施中の場合、セルの背景を変えて「過ぎている」ラベルを表示
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    cell.willDoLabel.backgroundColor = UIColor(red:0.196, green:0.804, blue:0.196, alpha:1.0)
                    cell.willDoLabel.text = "実施中"
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = false
                    cell.isBreederLabel.isHidden = false
                }else{
                    cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    cell.willDoLabel.backgroundColor = UIColor(red:0.196, green:0.804, blue:0.196, alpha:1.0)
                    cell.willDoLabel.text = "実施中"
                    cell.willDoLabel.isHidden = false
                    cell.overdueLabel.isHidden = true
                    cell.isBreederLabel.isHidden = false
                }
                // 中止
            } else if self.leaveDataArray[indexPath.row].stopFlag == true {
                cell.backgroundColor = UIColor.white
                cell.willDoLabel.text = "中止"
                cell.willDoLabel.backgroundColor = UIColor.gray
                cell.willDoLabel.isHidden = false
                cell.overdueLabel.isHidden = true
                cell.isBreederLabel.isHidden = false
                // 中断
            } else if self.leaveDataArray[indexPath.row].abortFlag == true {
                cell.backgroundColor = UIColor.white
                cell.willDoLabel.text = "中断"
                cell.willDoLabel.backgroundColor = UIColor.gray
                cell.willDoLabel.isHidden = false
                cell.overdueLabel.isHidden = true
                cell.isBreederLabel.isHidden = false
                // 完了
            } else if self.leaveDataArray[indexPath.row].completeFlag == true {
                cell.backgroundColor = UIColor.white
                cell.willDoLabel.text = "完了"
                cell.willDoLabel.backgroundColor = UIColor.gray
                cell.willDoLabel.isHidden = false
                cell.overdueLabel.isHidden = true
                cell.isBreederLabel.isHidden = false
            }
        }
        
        print("DEBUG_PRINT: TodoListViewController.cellForRowAt end")
        return cell
    }
    
    
    func read() {
        print("DEBUG_PRINT: TodoListViewController.read start")
        // userのleaveを取得
        if UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds) != nil &&
            !(UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)?.isEmpty)! {
            // leaveDataリストの取得
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            for (leaveId,_) in UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)! {
                let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(leaveId).queryOrderedByKey()
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print("DEBUG_PRINT: TodoListViewController.read .observeSingleEventイベントが発生しました。")
                    if let _ = snapshot.value as? NSDictionary {
                        // leaveを取得
                        let leaveData = LeaveData(snapshot: snapshot, myId: leaveId)
                        self.leaveDataArray.append(leaveData)
                        
                        // 更新日で並び替え
                        self.leaveDataArray = self.leaveDataArray.sorted(by: {
                            DateCommon.stringToDate($0.startDate!, dateFormat: DateCommon.dateFormat).compare(DateCommon.stringToDate($1.startDate!, dateFormat: DateCommon.dateFormat)) == ComparisonResult.orderedDescending
                        })
                    }
                    
                    // tableViewを再表示する
                    if UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)!.count == self.leaveDataArray.count {
                        DispatchQueue.main.async {
                            print("DEBUG_PRINT: TodoListViewController.read [DispatchQueue.main.async]")
                            self.reload(leaveDataArray: self.leaveDataArray)
                            SVProgressHUD.dismiss()
                        }
                    }
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
                }
            }
        }
        print("DEBUG_PRINT: TodoListViewController.read end")
    }
    
    func reload(leaveDataArray: [LeaveData]) {
        print("DEBUG_PRINT: TodoListViewController.reload start")
        //テーブルビューをリロード
        self.tableView.reloadData()
        print("DEBUG_PRINT: TodoListViewController.reload end")
    }
    
    // TODOラベルがタップされたらメッセージ画面に遷移
    func handleLeaveInfoButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: TodoListViewController.handleLeaveInfoButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // Leave画面に遷移
        // leaveDataをセットして画面遷移
        let leaveViewController = self.storyboard?.instantiateViewController(withIdentifier: "Leave") as! LeaveViewController
        leaveViewController.leaveData = self.leaveDataArray[(indexPath?.row)!]
        self.navigationController?.pushViewController(leaveViewController, animated: true)
        
        print("DEBUG_PRINT: TodoListViewController.handleLeaveInfoButton end")
    }
    // ユーザープロフィールがタップされたらユーザー詳細画面に遷移
    func handleUserDetailButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: TodoListViewController.handleUserDetailButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 画面遷移
        if let userId = self.leaveDataArray[(indexPath?.row)!].userId {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: TodoListViewController.handleUserDetailButton .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let userData = UserData(snapshot: snapshot, myId: userId)
                    let userDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailViewController
                    userDetailViewController.userData = userData
                    self.navigationController?.pushViewController(userDetailViewController, animated: true)
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        }
        
        print("DEBUG_PRINT: TodoListViewController.handleUserDetailButton end")
    }
    
    // ペットプロフィールがタップされたらペット詳細画面に遷移
    func handlePetDetailButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: TodoListViewController.handlePetDetailButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 画面遷移
        if let petId = self.leaveDataArray[(indexPath?.row)!].petId {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: TodoListViewController.handlePetDetailButton .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let petData = PetData(snapshot: snapshot, myId: petId)
                    let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
                    petDetailViewController.petData = petData
                    self.navigationController?.pushViewController(petDetailViewController, animated: true)
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        }
        
        print("DEBUG_PRINT: TodoListViewController.handlePetDetailButton end")
    }
}
