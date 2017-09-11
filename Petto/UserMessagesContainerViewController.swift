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
    
    let topViewController: MessagesViewController  // ViewController①を保持
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
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if let roomId = self.roomData?.id {
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
                // 要素が追加されたら再表示
                let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(roomId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                    if let _ = snapshot.value as? NSDictionary {                        
                        self.leaveData = LeaveData(snapshot: snapshot, myId: uid)
                    }
                    self.setView()
                    SVProgressHUD.dismiss()

                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewDidLoad end")
    }
    
    func setView(){
        print("DEBUG_PRINT: UserMessagesContainerViewController.setView start")
        
        if self.leaveData == nil {
            // ViewController①をContainerViewControllerの子として追加
            topViewController.roomData = self.roomData
            addChildViewController(topViewController)
            
            // ViewController①の表示
            view.addSubview(topViewController.view)
            topViewController.didMove(toParentViewController: self)
            topViewController.view.frame = CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height - 60)
        }else{
            // ViewController①をContainerViewControllerの子として追加
            topViewController.roomData = self.roomData
            addChildViewController(topViewController)
            
            // ViewController①の表示
            view.addSubview(topViewController.view)
            topViewController.didMove(toParentViewController: self)
            topViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 210)
            
            // ViewController②をContainerViewControllerの子として追加
            underViewController.roomData = self.roomData
            underViewController.leaveData = self.leaveData
            addChildViewController(underViewController)
            
            // ViewController②の表示
            view.addSubview(underViewController.view)
            underViewController.didMove(toParentViewController: self)
            underViewController.view.frame = CGRect(x: 0, y: view.frame.height - 210, width: view.frame.width, height: 210)
        }
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.setView end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewWillDisappear start")
        
        if let roomId = self.roomData?.id {
            let ref = FIRDatabase.database().reference().child(Paths.LeavePath).child(roomId)
            ref.removeAllObservers()
        }
        
        print("DEBUG_PRINT: UserMessagesContainerViewController.viewWillDisappear end")
    }
}
