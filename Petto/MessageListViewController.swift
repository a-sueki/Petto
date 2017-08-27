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

class MessageListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var roomIdList: [String] = []
    var userData: UserData?
    var petDataArray: [PetData] = []
    var messageDataArray: [MessageData] = []
    
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MessageListViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MessageListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "messageListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        print("DEBUG_PRINT: MessageListViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear start")
        
        // userのmessages[]を取得　→roomIdList
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            // Userのメッセージリスト（roomIdList）の取得
            ref.observe(.value, with: { (snapshot) in
                print("DEBUG_PRINT: MessageListViewController.viewWillAppear .valueイベントが発生しました。")
                print(snapshot)
                print("DEBUG_PRINT: MessageListViewController.viewWillAppear 1")
                self.userData = UserData(snapshot: snapshot, myId: uid)
                print("DEBUG_PRINT: MessageListViewController.viewWillAppear 2")
                print(self.userData?.myMessages)
                
                // user,petデータを取得
                for (key, value) in (self.userData?.myMessages)! {
                    print("DEBUG_PRINT: MessageListViewController.viewWillAppear 3")
                    print(key)
                    self.roomIdList.append(key)
                    self.getData(roomId: key)
                }
                // tableViewを再表示する
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
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
            }
            
            // ログイン画面に遷移
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        }
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear end")
    }
    
    func getData(roomId: String) {
        print("DEBUG_PRINT: MessageListViewController.getData start")
        
        // pidの取得
        let uidNum = userData?.id?.characters.count
        let currentIndex = roomId.index(roomId.startIndex, offsetBy: uidNum!)
        let pid = roomId.substring(from: currentIndex)
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear 4")
        print(pid)
        // PetDataの取得
        let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(pid)
        ref.observe(.value, with: { (snapshot) in
            print("DEBUG_PRINT: MessageListTableViewCell.getData pid.valueイベントが発生しました。")
            for v in snapshot.children {
                print("DEBUG_PRINT: MessageListViewController.viewWillAppear 5")
                print(v)
                if v is FIRDataSnapshot {
                    print("DEBUG_PRINT: MessageListViewController.viewWillAppear 6")
                    let petData = PetData(snapshot: snapshot, myId: pid)
                    self.petDataArray.append(petData)
                    print(self.petDataArray)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Messageを取得
        let ref2 = FIRDatabase.database().reference().child(Paths.MessagePath).child(roomId)
        ref2.observe(.value, with: { (snapshot) in
            print("DEBUG_PRINT: MessageListTableViewCell.getData roomId.valueイベントが発生しました。")
            for v in snapshot.children {
                if v is FIRDataSnapshot {
                    let messageData = MessageData(snapshot: snapshot, myId: roomId)
                    self.messageDataArray.append(messageData)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
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
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! MessageListTableViewCell
        //TODO: messagesでtextの最新メッセージを取得
        cell.setData(userData: self.userData!, petData: self.petDataArray[indexPath.row], messageData: self.messageDataArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.messageLabelButton.addTarget(self, action:#selector(handleMessageLabelButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
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
        
        let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        messagesViewController.uid = self.userData?.id
        messagesViewController.pid = self.petDataArray[indexPath!.row].id
        self.navigationController?.pushViewController(messagesViewController, animated: true)
        
        print("DEBUG_PRINT: MessageListViewController.handleMessageLabelButton end")
    }
    
    
}
