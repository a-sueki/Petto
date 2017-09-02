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
    var userDefaults: UserDefaults?
    var roomIdList: [String] = []
    var userData: UserData?
    var roomDataArray: [RoomData] = []
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MessageListViewController.viewDidLoad start")
        
        self.userDefaults = UserDefaults.standard

        print("DEBUG_PRINT: MessageListViewController 1")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MessageListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "messageListCell")
        tableView.rowHeight = UITableViewAutomaticDimension

        print("DEBUG_PRINT: MessageListViewController.viewDidLoad end")
    }

    override func viewWillAppear(_ animated: Bool) {
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear start")

        print("DEBUG_PRINT: MessageListViewController 2")
        
        //TODO: BaseViewControllerでやる？
        
        // userのmessages[]を取得　→roomIdList
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            print("DEBUG_PRINT: MessageListViewController 3")
            // HUDで処理中を表示
            SVProgressHUD.show()
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            // Userのメッセージリスト（roomIdList）の取得
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: MessageListViewController.viewWillAppear .observeSingleEventイベントが発生しました。")
                self.userData = UserData(snapshot: snapshot, myId: uid)
                if self.userData?.roomIds.count != 0 {
                    // user,petデータを取得
                    for (key, _) in (self.userData?.roomIds)! {
                        self.roomIdList.append(key)
                        self.getData(roomId: key)
                    }
                    print("DEBUG_PRINT: MessageListViewController 4")
                    // tableViewを再表示する
                    self.tableView.reloadData()
                    // HUDを消す
                    SVProgressHUD.dismiss()
                }else{
                    print("DEBUG_PRINT: MessageListViewController 5")
                    //roomが0件の時は「メッセージ送受信はありません」を表示
                    SVProgressHUD.showError(withStatus: "まだメッセージがありません")
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
            print("DEBUG_PRINT: MessageListViewController 6")
            self.observing = true
        }else{
            print("DEBUG_PRINT: MessageListViewController.viewWillAppear ユーザがログインしていません。")
            // ログインしていない場合
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                roomIdList = []
                self.tableView.reloadData()
                // オブザーバーを削除する
                FIRDatabase.database().reference().removeAllObservers()
                // FIRDatabaseのobserveEventが上記コードにより解除されたためfalseとする
                observing = false
                SVProgressHUD.showError(withStatus: "再度、ログインしてお試し下さい")
            }
            
            // ログイン画面に遷移
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        }
        print("DEBUG_PRINT: MessageListViewController 7")
        
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear end")
    }
    
    func getData(roomId: String) {
        print("DEBUG_PRINT: MessageListViewController.getData start")
        
        // HUDで処理中を表示
        SVProgressHUD.show()
        print("DEBUG_PRINT: MessageListViewController 8")

        // roomDataリストの取得
        let ref = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MessageListTableViewCell.getData .observeSingleEventイベントが発生しました。")
            if let _ = snapshot.value as? NSDictionary {
                let roomData = RoomData(snapshot: snapshot, myId: roomId)
                self.roomDataArray.append(roomData)
                print("DEBUG_PRINT: MessageListViewController 9")
                // tableViewを再表示する
                self.tableView.reloadData()
                // HUDを消す
                SVProgressHUD.dismiss()
            }
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
       }
        print("DEBUG_PRINT: MessageListViewController 10")

        print("DEBUG_PRINT: MessageListViewController.getData end")
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
        
        print("DEBUG_PRINT: MessageListViewController 11")
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! MessageListTableViewCell
        
        // roomDataリスト取得（非同期）の完了前のテーブル表示エラー防止のため
        if self.roomIdList.count == self.roomDataArray.count {
            
            print("DEBUG_PRINT: MessageListViewController 12")
            cell.setData(userData: self.userData!, roomData: self.roomDataArray[indexPath.row])

            // 未読の場合、ハイライト
            if self.userData?.unReadRoomIds.count != 0 {
                print("DEBUG_PRINT: MessageListViewController 13")

                for (rid,_) in (self.userData?.unReadRoomIds)! {
                    print("DEBUG_PRINT: MessageListViewController 14")

                    if rid == self.roomDataArray[indexPath.row].id {
                        cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                    }else{
                        cell.unReadLabel.isHidden = true
                    }
                }
            }
            // セル内のボタンのアクションをソースコードで設定する
            cell.messageLabelButton.addTarget(self, action:#selector(handleMessageLabelButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        }
        print("DEBUG_PRINT: MessageListViewController 15")
        
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
        // 自分のuidを取得
        let uid = self.userDefaults?.string(forKey: DefaultString.Uid)!

        // 既読フラグupdate
        if let roomId = self.roomDataArray[(indexPath?.row)!].id {
            if roomId.contains(uid!) {
                // 自分があずかり人の場合
                ref.child(Paths.RoomPath).child(roomId).updateChildValues(["userOpenedFlg" : true])
                ref.child(Paths.UserPath).child(uid!).child("unReadRoomIds").child(roomId).removeValue()
                // roomDataをセットして画面遷移
                let messagesContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserMessagesContainer") as! UserMessagesContainerViewController
                messagesContainerViewController.roomData = self.roomDataArray[(indexPath?.row)!]
                self.navigationController?.pushViewController(messagesContainerViewController, animated: true)
            }else{
                // 自分がブリーダーの場合
                ref.child(Paths.RoomPath).child(roomId).updateChildValues(["petOpenedFlg" : true])
                ref.child(Paths.UserPath).child(uid!).child("unReadRoomIds").child(roomId).removeValue()
                // roomDataをセットして画面遷移
                let messagesContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "BreederMessagesContainer") as! BreederMessagesContainerViewController
                messagesContainerViewController.roomData = self.roomDataArray[(indexPath?.row)!]
                self.navigationController?.pushViewController(messagesContainerViewController, animated: true)
            }
        }
        print("DEBUG_PRINT: MessageListViewController.handleMessageLabelButton end")
    }
}
