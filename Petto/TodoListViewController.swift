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
    
    var leaveIdList: [String] = []
    var leaveDataArray: [LeaveData] = []
    var sortedLeaveDataArray: [LeaveData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: TodoListViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "TodoListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "todoListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // userのTodoRoomIdsからleaveIdを取得
        if UserDefaults.standard.object(forKey: DefaultString.TodoRoomIds) != nil {
            
            for (key, _) in UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)!{
                leaveIdList.append(key)
                self.getDataSingleEvent(leaveId: key)
            }
        }else{
            //todoRoomIdsが0件の時は「TODOはありません」を表示
            SVProgressHUD.showError(withStatus: "TODOはありません")
        }
        
        print("DEBUG_PRINT: TodoListViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: TodoListViewController.viewWillAppear start")
        
        var leaveIdListAgain: [String] = []
        
        // userのTodoRoomIdsからleaveIdを取得
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        if UserDefaults.standard.object(forKey: DefaultString.TodoRoomIds) != nil {
            for (key, _) in UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)!{
                leaveIdListAgain.append(key)
                // 未実施→実施済に更新
                let ref = FIRDatabase.database().reference().child(Paths.UserPath)
                // 未実施なしの場合のユーザーデフォルトの設定
                UserDefaults.standard.set([String:Bool]() , forKey: DefaultString.TodoRoomIds)
                // todoRoomIds取得
                var todoRoomIds = [String:Bool]()
                ref.child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("todoRoomIds").observe(.childAdded, with: { (snapshot) in
                    print("DEBUG_PRINT: TodoListViewController.viewWillAppear todoRoomIds.childAddedイベントが発生しました。")
                    if case _ as Bool = snapshot.value {
                        todoRoomIds[snapshot.key] = true
                    }
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(todoRoomIds , forKey: DefaultString.TodoRoomIds)
                    // tableViewを再表示する
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }else{
            //todoRoomIdsが0件の時は「TODOはありません」を表示
            SVProgressHUD.showError(withStatus: "TODOはありません")
        }
        // tableViewを再表示する
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
        
        // 比較用にsort
        let ascendingOldList : [String] = leaveIdList.sorted(by: {$0 < $1})
        let ascendingNewList : [String] = leaveIdListAgain.sorted(by: {$0 < $1})
        
        // leaveIdListの内容が変わっていた場合（削除・追加）
        if ascendingOldList != ascendingNewList {
            print("DEBUG_PRINT: TodoListViewController.viewWillAppear leaveIdListの内容が変更されました")
            // リストを初期化
            self.leaveDataArray.removeAll()
            self.sortedLeaveDataArray.removeAll()
            // リストを再取得・テーブルreloadData
            for key in ascendingNewList {
                self.getDataSingleEvent(leaveId: key)
            }
        }
        
        print("DEBUG_PRINT: TodoListViewController.viewWillAppear end")
    }
    
    func getDataSingleEvent(leaveId: String) {
        print("DEBUG_PRINT: TodoListViewController.getDataSingleEvent start")
        
        // leaveDataリストの取得
        let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(leaveId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: TodoListViewController.getDataSingleEvent .observeSingleEventイベントが発生しました。")
            if let _ = snapshot.value as? NSDictionary {
                let leaveData = LeaveData(snapshot: snapshot, myId: leaveId)
                self.leaveDataArray.append(leaveData)
                // 開始日で並び替え
                self.sortedLeaveDataArray = self.leaveDataArray.sorted(by: {
                    
                    DateCommon.stringToDate($0.startDate!, dateFormat: DateCommon.dateFormat).compare(DateCommon.stringToDate($1.startDate!, dateFormat: DateCommon.dateFormat)) == ComparisonResult.orderedDescending
                })
                // tableViewを再表示する
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print("DEBUG_PRINT: TodoListViewController.getDataSingleEvent end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveIdList.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: TodoListViewController.cellForRowAt start")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoListCell", for: indexPath) as! TodoListTableViewCell
        // セル内のボタンのアクションをソースコードで設定する
        cell.leaveInfoButton.addTarget(self, action:#selector(handleLeaveInfoButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.userDetailButton.addTarget(self, action:#selector(handleUserDetailButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.petDetailButton.addTarget(self, action:#selector(handlePetDetailButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        
        
        // leaveDataリスト取得（非同期）の完了前のテーブル表示エラー防止のため
        if self.leaveIdList.count == self.sortedLeaveDataArray.count {
            cell.setData(leaveData: self.sortedLeaveDataArray[indexPath.row])
            
            // あずかり人の場合
            if self.sortedLeaveDataArray[indexPath.row].breederId != UserDefaults.standard.string(forKey: DefaultString.Uid) {
                // 未実施の場合
                if self.sortedLeaveDataArray[indexPath.row].acceptFlag == true &&
                    DateCommon.stringToDate(self.sortedLeaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
                    cell.willDoLabel.isHidden = false
                    cell.isBreederLabel.isHidden = true
                }else{
                    cell.willDoLabel.isHidden = true
                    cell.isBreederLabel.isHidden = true
                }
            }else{
                // 未実施の場合
                if self.sortedLeaveDataArray[indexPath.row].acceptFlag == true &&
                    DateCommon.stringToDate(self.sortedLeaveDataArray[indexPath.row].startDate!, dateFormat: DateCommon.dateFormat).compare(Date()) == ComparisonResult.orderedAscending {
                    cell.willDoLabel.isHidden = false
                    cell.isBreederLabel.isHidden = false
                }else{
                    cell.willDoLabel.isHidden = true
                    cell.isBreederLabel.isHidden = false
                }
            }
        }
        
        print("DEBUG_PRINT: TodoListViewController.cellForRowAt end")
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
    
    // メッセージラベルがタップされたらメッセージ画面に遷移
    func handleLeaveInfoButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: TodoListViewController.handleLeaveInfoButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //TODO: Leave画面に遷移
        let leave = self.sortedLeaveDataArray[(indexPath?.row)!]
        if leave.userId == UserDefaults.standard.string(forKey: DefaultString.Uid)! {
            // 自分があずかり人の場合
            // leaveDataをセットして画面遷移
/*            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let consentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Consent") as! ConsentViewController
            let userMessagesContainerViewController = UserMessagesContainerViewController(top: messagesViewController, under: consentViewController)
            userMessagesContainerViewController.roomData = self.sortedLeaveDataArray[(indexPath?.row)!]
            self.navigationController?.pushViewController(userMessagesContainerViewController, animated: true)
*/
        }else{
            // 自分がブリーダーの場合
            // leaveDataをセットして画面遷移
/*            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let bookingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Booking") as! BookingViewController
            let breederMessagesContainerViewController = BreederMessagesContainerViewController(top: messagesViewController, under: bookingViewController)
            breederMessagesContainerViewController.roomData = self.sortedLeaveDataArray[(indexPath?.row)!]
            self.navigationController?.pushViewController(breederMessagesContainerViewController, animated: true)
 */
        }
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
        if let userId = self.sortedLeaveDataArray[(indexPath?.row)!].userId {
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
            })
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
        if let petId = self.sortedLeaveDataArray[(indexPath?.row)!].petId {
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: TodoListViewController.handlePetDetailButton .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let petData = PetData(snapshot: snapshot, myId: petId)
                    let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
                    petDetailViewController.petData = petData
                    self.navigationController?.pushViewController(petDetailViewController, animated: true)
                }
            })
        }
        
        print("DEBUG_PRINT: TodoListViewController.handlePetDetailButton end")
    }
    
    
}
