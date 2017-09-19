//
//  UserMessagesContainerViewController.swift
//  Petto
//
//  Created by admin on 2017/09/02.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class UserMessagesContainerViewController: UIViewController {
    
    var roomData: RoomData?
    var messageData: MessageData?
    var leaveData: LeaveData?
    
    let topViewController:  MessagesViewController // ViewController①を保持
    let underViewController: ConsentViewController  // ViewController②を保持
    
    // ContainerViewControllerにViewController①と②をセットするイニシャライザ
    init(top:MessagesViewController, under:ConsentViewController){
        print("DEBUG_PRINT: UserMessagesContainerViewController.init start")
        
        topViewController = top
        underViewController = under
        
        super.init(nibName:nil, bundle:nil)
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.init end")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad start")

        // Firebaseから登録済みデータを取得
        if let uid = FIRAuth.auth()?.currentUser?.uid, self.roomData?.todoRoomIds != nil, !(self.roomData?.todoRoomIds.isEmpty)!{
            SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
            for (leaveId,_) in (self.roomData?.todoRoomIds)! {
                let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(leaveId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                    if let _ = snapshot.value as? NSDictionary {
                        let leave = LeaveData(snapshot: snapshot, myId: uid)
                        // 未承諾
                        if leave.suggestFlag == true && leave.acceptFlag == false{
                            self.leaveData = leave
                        }else{
                            // 承諾後
                            if leave.acceptFlag == true && leave.runningFlag == false && leave.stopFlag == false && leave.abortFlag == false && leave.completeFlag == false{
                                // 未実施
                                self.leaveData = leave
                            }else if leave.acceptFlag == true && leave.runningFlag == true, leave.stopFlag == false && leave.abortFlag == false && leave.completeFlag == false{
                                // 実施中
                                self.leaveData = leave
                            }else if leave.acceptFlag == true && leave.runningFlag == false , leave.stopFlag == true || leave.abortFlag == true || leave.completeFlag == true{
                                // 終了
                                // なにもしない
                            }
                        }
                    }
                    print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad a")
                    
                    self.setView()
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
                }
            }
        }else{
            print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad b")
           self.setView()
        }
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewWillDisappear start")
        
        if let _ = FIRAuth.auth()?.currentUser?.uid, self.roomData?.todoRoomIds != nil, !(self.roomData?.todoRoomIds.isEmpty)!{
            for (leaveId,_) in (self.roomData?.todoRoomIds)! {
                let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(leaveId)
                ref.removeAllObservers()
            }
        }
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewWillDisappear end")
    }
    
    func setView(){
        print("DEBUG_PRINT: UserMessagesContainerViewController.setView start")
        
        if self.leaveData == nil {
            print("DEBUG_PRINT: UserMessagesContainerViewController.setView 1")
            
            // ViewController①をContainerViewControllerの子として追加
            topViewController.roomData = self.roomData
            addChildViewController(topViewController)
            
            // ViewController①の表示
            view.addSubview(topViewController.view)
            topViewController.didMove(toParentViewController: self)
            topViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            
        }else{
            print("DEBUG_PRINT: UserMessagesContainerViewController.setView 2")
            
            // ViewController①をContainerViewControllerの子として追加
            topViewController.roomData = self.roomData
            addChildViewController(topViewController)
            
            // ViewController①の表示
            view.addSubview(topViewController.view)
            topViewController.didMove(toParentViewController: self)
            topViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 5 * 4)
            // ViewController②をContainerViewControllerの子として追加
            underViewController.roomData = self.roomData
            underViewController.leaveData = self.leaveData
            addChildViewController(underViewController)
            
            // ViewController②の表示
            view.addSubview(underViewController.view)
            underViewController.didMove(toParentViewController: self)
            underViewController.view.frame = CGRect(x: 0, y: view.frame.height / 5 * 4, width: view.frame.width, height: view.frame.height / 5)
        }
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.setView end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
