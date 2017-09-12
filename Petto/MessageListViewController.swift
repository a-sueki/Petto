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
    var roomDataArray: [RoomData] = []
    
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
        
        self.roomDataArray.removeAll()
        self.read()
        
        print("DEBUG_PRINT: MessageListViewController.viewWillAppear end")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DEBUG_PRINT: MessageListViewController.viewDidAppear start")
        print("DEBUG_PRINT: MessageListViewController.viewDidAppear end")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("DEBUG_PRINT: MessageListViewController.viewDidDisappear start")
        
        if UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds) != nil && (UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)?.isEmpty)! {
            for (roomId,_) in UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)! {
                let ref = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId)
                ref.removeAllObservers()
            }
        }
        
        for rooms in self.roomDataArray {
            if let userId = rooms.userId {
                let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(userId)
                ref.removeAllObservers()
            }
            if let petId = rooms.petId {
                let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
                ref.removeAllObservers()
            }
        }
        
        print("DEBUG_PRINT: MessageListViewController.viewDidDisappear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT: MessageListViewController.numberOfRowsInSection start")
        print("DEBUG_PRINT: MessageListViewController.numberOfRowsInSection end")
        return roomDataArray.count
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: MessageListViewController.didSelectRowAt start")
        
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print("DEBUG_PRINT: MessageListViewController.didSelectRowAt end")
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        print("DEBUG_PRINT: MessageListViewController.editingStyleForRowAt start")
        print("DEBUG_PRINT: MessageListViewController.editingStyleForRowAt end")
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        print("DEBUG_PRINT: MessageListViewController.estimatedHeightForRowAt start")
        print("DEBUG_PRINT: MessageListViewController.estimatedHeightForRowAt end")
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    //返すセルを決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: MessageListViewController.cellForRowAt start")
        
        //xibとカスタムクラスで作成したCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! MessageListTableViewCell
        // セル内のボタンのアクションをソースコードで設定する
        cell.messageLabelButton.addTarget(self, action:#selector(handleMessageLabelButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.userProfileButton.addTarget(self, action:#selector(handleUserProfileButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.petProfileButton.addTarget(self, action:#selector(handlePetProfileButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        
        cell.setData(roomData: self.roomDataArray[indexPath.row])
        
        // あずかり人の場合
        if self.roomDataArray[indexPath.row].breederId != UserDefaults.standard.string(forKey: DefaultString.Uid) {
            // 未読の場合
            if UserDefaults.standard.object(forKey: DefaultString.UnReadRoomIds) != nil,
                !(UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)?.isEmpty)! {
                // セルをハイライト
                for (rid,_) in UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)! {
                    if rid == self.roomDataArray[indexPath.row].id {
                        cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                        cell.unReadLabel.isHidden = false
                        cell.isBreederLabel.isHidden = true
                        break
                    }else{
                        cell.backgroundColor = UIColor.white
                        cell.unReadLabel.isHidden = true
                        cell.isBreederLabel.isHidden = true
                    }
                }
            }else{
                cell.backgroundColor = UIColor.white
                cell.unReadLabel.isHidden = true
                cell.isBreederLabel.isHidden = true
            }
        }else{
            // 未読の場合
            if UserDefaults.standard.object(forKey: DefaultString.UnReadRoomIds) != nil,
                !(UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)?.isEmpty)! {
                // セルをハイライト
                for (rid,_) in UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)! {
                    if rid == self.roomDataArray[indexPath.row].id {
                        cell.backgroundColor = UIColor(red:1.00, green:1.00, blue:0.88, alpha:1.0)
                        cell.isBreederLabel.isHidden = false
                        cell.unReadLabel.isHidden = false
                        break
                    }else{
                        cell.backgroundColor = UIColor.white
                        cell.isBreederLabel.isHidden = false
                        cell.unReadLabel.isHidden = true
                    }
                }
            }else{
                cell.backgroundColor = UIColor.white
                cell.isBreederLabel.isHidden = false
                cell.unReadLabel.isHidden = true
            }
        }
        
        print("DEBUG_PRINT: MessageListViewController.cellForRowAt end")
        return cell
    }
    
    
    func read() {
        print("DEBUG_PRINT: MessageListViewController.read start")
        // userのroomを取得
        if UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds) != nil && !(UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)?.isEmpty)! {
            // roomDataリストの取得
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            for (roomId,_) in UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)! {
                let ref = FIRDatabase.database().reference().child(Paths.RoomPath).child(roomId).queryOrderedByKey()
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print("DEBUG_PRINT: MessageListViewController.read .observeSingleEventイベントが発生しました。")
                    if let _ = snapshot.value as? NSDictionary {
                        // roomを取得
                        let roomData = RoomData(snapshot: snapshot, myId: roomId)
                        self.roomDataArray.append(roomData)
                        
                        // 更新日で並び替え
                        self.roomDataArray = self.roomDataArray.sorted(by: {
                            $0.updateAt?.compare($1.updateAt! as Date) == ComparisonResult.orderedDescending
                        })
                    }
                    // tableViewを再表示する
                    if UserDefaults.standard.dictionary(forKey: DefaultString.RoomIds)!.count == self.roomDataArray.count {
                        DispatchQueue.main.async {
                            print("DEBUG_PRINT: MessageListViewController.read [DispatchQueue.main.async]")
                            self.reload(roomDataArray: self.roomDataArray)
                            SVProgressHUD.dismiss()
                        }
                    }
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
                }
            }
        }
        print("DEBUG_PRINT: MessageListViewController.read end")
    }
    
    func reload(roomDataArray: [RoomData]) {
        print("DEBUG_PRINT: MessageListViewController.reload start")
        //テーブルビューをリロード
        self.tableView.reloadData()
        print("DEBUG_PRINT: MessageListViewController.reload end")
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
        let room = self.roomDataArray[(indexPath?.row)!]
        if room.userId == UserDefaults.standard.string(forKey: DefaultString.Uid)! {
            // 自分があずかり人の場合
            ref.child(Paths.UserPath).child(room.userId!).child("unReadRoomIds").child(room.id!).removeValue()
            // roomDataをセットして画面遷移
            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let consentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Consent") as! ConsentViewController
            let userMessagesContainerViewController = UserMessagesContainerViewController(top: messagesViewController, under: consentViewController)
            userMessagesContainerViewController.roomData = self.roomDataArray[(indexPath?.row)!]
            self.navigationController?.pushViewController(userMessagesContainerViewController, animated: true)
            
        }else{
            // 自分がブリーダーの場合
            ref.child(Paths.UserPath).child(room.breederId!).child("unReadRoomIds").child(room.id!).removeValue()
            // roomDataをセットして画面遷移
            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let bookingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Booking") as! BookingViewController
            let breederMessagesContainerViewController = BreederMessagesContainerViewController(top: messagesViewController, under: bookingViewController)
            breederMessagesContainerViewController.roomData = self.roomDataArray[(indexPath?.row)!]
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
        if let userId = self.roomDataArray[(indexPath?.row)!].userId {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: MessageListViewController.handleUserProfileButton .observeSingleEventイベントが発生しました。")
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
        if let petId = self.roomDataArray[(indexPath?.row)!].petId {
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            let ref = FIRDatabase.database().reference().child(Paths.PetPath).child(petId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: MessageListViewController.handlePetProfileButton .observeSingleEventイベントが発生しました。")
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
        
        print("DEBUG_PRINT: MessageListViewController.handlePetProfileButton end")
    }
 }
