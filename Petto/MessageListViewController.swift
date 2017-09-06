//
//  MessageListViewController.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class MessageListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var roomIdList: [String] = []
    var roomDataArray: [RoomData] = []
    var sortedRoomDataArray: [RoomData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MessageListViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MessageListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "messageListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // userのmessages[]を取得　→roomIdList
        if UserDefaults.standard.object(forKey: DefaultString.RoomIds) != nil {
            
            for (key, _) in UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)!{
                roomIdList.append(key)
                self.getDataSingleEvent(roomId: key)
            }
        }else{
            //roomが0件の時は「メッセージ送受信はありません」を表示
            SVProgressHUD.showError(withStatus: "まだメッセージがありません")
        }
        
        print("DEBUG_PRINT: MessageListViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear start")
        
        var roomIdListAgain: [String] = []
        
        // userのmessages[]を取得　→roomIdList
        if UserDefaults.standard.object(forKey: DefaultString.RoomIds) != nil {
            
            for (key, _) in UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)!{
                roomIdListAgain.append(key)
                // 未読→既読に更新
                let ref = FIRDatabase.database().reference().child(Paths.UserPath)
                // 未読なしの場合のユーザーデフォルトの設定
                UserDefaults.standard.set([String:Bool]() , forKey: DefaultString.UnReadRoomIds)
                // UnReadRoomIds取得
                var unReadRoomIds = [String:Bool]()
                ref.child(UserDefaults.standard.string(forKey: DefaultString.Uid)!).child("unReadRoomIds").observe(.childAdded, with: { (snapshot) in
                    print("DEBUG_PRINT: MessageListViewController.viewWillAppear unReadRoomIds.childAddedイベントが発生しました。")
                    if case _ as Bool = snapshot.value {
                        unReadRoomIds[snapshot.key] = true
                    }
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(unReadRoomIds , forKey: DefaultString.UnReadRoomIds)
                    // tableViewを再表示する
                    self.tableView.reloadData()
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }else{
            //roomが0件の時は「メッセージ送受信はありません」を表示
            SVProgressHUD.showError(withStatus: "まだメッセージがありません")
        }
        // tableViewを再表示する
        self.tableView.reloadData()
        
        // 比較用にsort
        let ascendingOldList : [String] = roomIdList.sorted(by: {$0 < $1})
        let ascendingNewList : [String] = roomIdListAgain.sorted(by: {$0 < $1})
        
        // roomIdListの内容が変わっていた場合（削除・追加）
        if ascendingOldList != ascendingNewList {
            print("DEBUG_PRINT: MessageListViewController.viewWillAppear roomIdListの内容が変更されました")
            // リストを初期化
            self.roomDataArray.removeAll()
            self.sortedRoomDataArray.removeAll()
            // リストを再取得・テーブルreloadData
            for key in ascendingNewList {
                self.getDataSingleEvent(roomId: key)
            }
        }
        
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear end")
    }
    
    func getDataSingleEvent(roomId: String) {
        print("DEBUG_PRINT: MessageListViewController.getDataSingleEvent start")
        
        // roomDataリストの取得
        let ref = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MessageListViewController.getDataSingleEvent .observeSingleEventイベントが発生しました。")
            if let _ = snapshot.value as? NSDictionary {
                let roomData = RoomData(snapshot: snapshot, myId: roomId)
                self.roomDataArray.append(roomData)
                // 更新日で並び替え
                self.sortedRoomDataArray = self.roomDataArray.sorted(by: {
                    $0.updateAt?.compare($1.updateAt! as Date) == ComparisonResult.orderedDescending
                })
                // tableViewを再表示する
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print("DEBUG_PRINT: MessageListViewController.getDataSingleEvent end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomIdList.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: MessageListViewController.cellForRowAt start")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! MessageListTableViewCell
        // セル内のボタンのアクションをソースコードで設定する
        cell.messageLabelButton.addTarget(self, action:#selector(handleMessageLabelButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.userProfileButton.addTarget(self, action:#selector(handleUserProfileButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.petProfileButton.addTarget(self, action:#selector(handlePetProfileButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        // roomDataリスト取得（非同期）の完了前のテーブル表示エラー防止のため
        if self.roomIdList.count == self.sortedRoomDataArray.count {
            cell.setData(roomData: self.sortedRoomDataArray[indexPath.row])
            
            // 未読の場合
            if UserDefaults.standard.object(forKey: DefaultString.UnReadRoomIds) != nil,
                !(UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)?.isEmpty)! {
                
                // セルをハイライト
                for (rid,_) in UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)! {
                    if rid == self.sortedRoomDataArray[indexPath.row].id {
                        cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                        cell.unReadLabel.isHidden = false
                        break
                    }else{
                        cell.backgroundColor = UIColor.white
                        cell.unReadLabel.isHidden = true
                    }
                }
            }else{
                cell.backgroundColor = UIColor.white
                cell.unReadLabel.isHidden = true
            }
        }
        
        print("DEBUG_PRINT: MessageListViewController.cellForRowAt end")
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
    func handleMessageLabelButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: MessageListViewController.handleMessageLabelButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 辞書を作成
        let ref = FIRDatabase.database().reference()
        
        // 既読フラグupdate
        let room = self.sortedRoomDataArray[(indexPath?.row)!]
        if room.userId == UserDefaults.standard.string(forKey: DefaultString.Uid)! {
            // 自分があずかり人の場合
            ref.child(Paths.UserPath).child(room.userId!).child("unReadRoomIds").child(room.id!).removeValue()
            // roomDataをセットして画面遷移
            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let consentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Consent") as! ConsentViewController
            let userMessagesContainerViewController = UserMessagesContainerViewController(top: messagesViewController, under: consentViewController)
            userMessagesContainerViewController.roomData = self.sortedRoomDataArray[(indexPath?.row)!]
            self.navigationController?.pushViewController(userMessagesContainerViewController, animated: true)
            
        }else{
            // 自分がブリーダーの場合
            ref.child(Paths.UserPath).child(room.breederId!).child("unReadRoomIds").child(room.id!).removeValue()
            // roomDataをセットして画面遷移
            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let bookingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Booking") as! BookingViewController
            let breederMessagesContainerViewController = BreederMessagesContainerViewController(top: messagesViewController, under: bookingViewController)
            breederMessagesContainerViewController.roomData = self.sortedRoomDataArray[(indexPath?.row)!]
            self.navigationController?.pushViewController(breederMessagesContainerViewController, animated: true)
        }
        print("DEBUG_PRINT: MessageListViewController.handleMessageLabelButton end")
    }
    
    // ユーザープロフィールがタップされたらユーザー詳細画面に遷移
    func handleUserProfileButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: MessageListViewController.handleUserProfileButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 画面遷移
        if let userId = self.sortedRoomDataArray[(indexPath?.row)!].userId {
            let userDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailViewController
            userDetailViewController.uid = userId
            self.navigationController?.pushViewController(userDetailViewController, animated: true)
        }
        print("DEBUG_PRINT: MessageListViewController.handleUserProfileButton end")
    }
    
    // ペットプロフィールがタップされたらペット詳細画面に遷移
    func handlePetProfileButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: MessageListViewController.handlePetProfileButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 画面遷移
        if let petId = self.sortedRoomDataArray[(indexPath?.row)!].petId {
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: MessageListViewController.handlePetProfileButton .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    let petData = PetData(snapshot: snapshot, myId: petId)
                    let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
                    petDetailViewController.petData = petData
                    self.navigationController?.pushViewController(petDetailViewController, animated: true)
                }
            })
        }
        
        print("DEBUG_PRINT: MessageListViewController.handlePetProfileButton end")
    }
    
    
}
