//
//  BaseViewController.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Eureka
import RKNotificationHub
import UserNotifications
import SVProgressHUD

class NavigationBarHandler: NSObject {
    
    var myUserData: UserData?
    
    // RKNotificationHubのインスタンス
    let hub = RKNotificationHub()
    
    weak var viewController: UIViewController?
    
    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!
    
    func setupNavigationBar() {
        print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar start")
        
        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        button1.setImage(UIImage(named: "menu"), for: .normal)
        button1.addTarget(self, action: #selector(onClick1), for: .touchUpInside)
        let button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 25))
        button2.setImage(UIImage(named: "logo"), for: .normal)
        button2.addTarget(self, action: #selector(onClick2), for: .touchUpInside)
        let button3 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        button3.setImage(UIImage(named: "todolist"), for: .normal)
        button3.addTarget(self, action: #selector(onClick3), for: .touchUpInside)
        let button4 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        button4.setImage(UIImage(named: "mail"), for: .normal)
        button4.addTarget(self, action: #selector(onClick4), for: .touchUpInside)
        let button5 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        button5.setImage(UIImage(named: "search"), for: .normal)
        button5.addTarget(self, action: #selector(onClick5), for: .touchUpInside)
        
        // userを取得
        if let user = FIRAuth.auth()?.currentUser ,!UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            let ref = FIRDatabase.database().reference().child(Paths.UserPath)
            ref.child(user.uid).observe(.value, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar .valueイベントが発生しました。")
                if let _ = snapshot.value {
                    self.myUserData = UserData(snapshot: snapshot, myId: user.uid)
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set([String:Bool](), forKey: DefaultString.UnReadRoomIds)
                    if self.myUserData?.unReadRoomIds != nil && !(self.myUserData?.unReadRoomIds.isEmpty)! {
                        // ユーザーデフォルト設定
                        UserDefaults.standard.set(self.myUserData?.unReadRoomIds , forKey: DefaultString.UnReadRoomIds)
                        // 未読
                        var unReadRoomIds = 0
                        for (_,v) in (self.myUserData?.unReadRoomIds)! {
                            if v {
                                unReadRoomIds = unReadRoomIds + 1
                            }
                        }
                        self.setNotificationBatch(button: button4, count: unReadRoomIds)
                    }
                    UserDefaults.standard.set([String:Bool](), forKey: DefaultString.TodoRoomIds)
                    if self.myUserData?.todoRoomIds != nil && !(self.myUserData?.todoRoomIds.isEmpty)! {
                        // ユーザーデフォルト設定
                        UserDefaults.standard.set(self.myUserData?.todoRoomIds , forKey: DefaultString.TodoRoomIds)
                        // TODO
                        var todoRoomIds = 0
                        for (k,v) in (self.myUserData?.todoRoomIds)! {
                            if v {
                                todoRoomIds = todoRoomIds + 1
                                // leaveを取得
                                self.readLeaveData(leaveId: k)
                            }
                        }
                        self.setNotificationBatch(button: button3, count: todoRoomIds)
                    }
                    UserDefaults.standard.set([String:Bool](), forKey: DefaultString.RoomIds)
                    if self.myUserData?.roomIds != nil && !(self.myUserData?.roomIds.isEmpty)! {
                        // ユーザーデフォルト設定
                        UserDefaults.standard.set(self.myUserData?.roomIds , forKey: DefaultString.RoomIds)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        } else {
            print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar ゲストユーザです。")
        }
        
        btn1 = UIBarButtonItem(customView: button1)
        btn2 = UIBarButtonItem(customView: button2)
        btn3 = UIBarButtonItem(customView: button3)
        btn4 = UIBarButtonItem(customView: button4)
        btn5 = UIBarButtonItem(customView: button5)
        
        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.viewController?.navigationItem.leftBarButtonItems = leftBtns
        self.viewController?.navigationItem.rightBarButtonItems = rightBtns
        
        print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar end")
        
    }
    
    func setNotificationBatch(button: UIButton, count: Int) {
        print("DEBUG_PRINT: NavigationBarHandler.setNotificationBatch start")
        
        // 通知バッチの更新
        if count != 0 {
            // 通知バッチをセット
            self.hub.setView(button, andCount: Int32(count))
            // 設置するhubの背景色をredに文字色を白にする
            self.hub.setCircleColor(UIColor.red, label: UIColor.white)
            // バッチのサイズを変更
            self.hub.scaleCircleSize(by: 0.8)
        }
        
        print("DEBUG_PRINT: NavigationBarHandler.setNotificationBatch end")
    }
    
    func readLeaveData(leaveId: String) {
        print("DEBUG_PRINT: NavigationBarHandler.readLeaveData start")
        
        let ref = FIRDatabase.database().reference().child(Paths.LeavePath)
        ref.child(leaveId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar .observeSingleEventイベントが発生しました。")
            if let _ = snapshot.value {
                let leaveData = LeaveData(snapshot: snapshot, myId: leaveId)
                if leaveData.acceptFlag! && !leaveData.runningFlag! && !leaveData.stopFlag! && !leaveData.abortFlag! && !leaveData.completeFlag! {
                    //TODO: おあずけ開始（予定）が今日より未来の場合
                    self.registerLocalNotification(leaveData: leaveData)
                }
                
            }
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
        }
        
        print("DEBUG_PRINT: NavigationBarHandler.readLeaveData end")
    }
    
    func registerLocalNotification(leaveData: LeaveData) {
        print("DEBUG_PRINT: NavigationBarHandler.registerLocalNotification start")
        
        //　通知設定に必要なクラスをインスタンス化
        let trigger: UNNotificationTrigger
        let content = UNMutableNotificationContent()
        var notificationTime = DateComponents()
        
        let start = leaveData.startDate!
        
        let y = start.substring(with: start.index(start.startIndex, offsetBy: 0)..<start.index(start.endIndex, offsetBy: -21))
        let m = start.substring(with: start.index(start.startIndex, offsetBy: 5)..<start.index(start.endIndex, offsetBy: -18))
        let d = start.substring(with: start.index(start.startIndex, offsetBy: 8)..<start.index(start.endIndex, offsetBy: -15))
        let h = start.substring(with: start.index(start.startIndex, offsetBy: 11)..<start.index(start.endIndex, offsetBy: -12))
        let mm = start.substring(with: start.index(start.startIndex, offsetBy: 14)..<start.index(start.endIndex, offsetBy: -9))
        
        // トリガー設定
        notificationTime.year = Int(y)
        notificationTime.month = Int(m)
        notificationTime.day = Int(d)! - 1
        notificationTime.hour = Int(h)
        notificationTime.minute = Int(mm)
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        
        // 通知内容の設定
        content.title = "Pettoリマインド通知"
        if leaveData.userId == FIRAuth.auth()?.currentUser?.uid {
            content.body = "明日がペット（\(leaveData.petName!)）の引き取り日です！"
        }else{
            content.body = "明日がペット（\(leaveData.petName!)）の引き渡し日です！"
        }
        content.sound = UNNotificationSound.default()
        content.badge = 29
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "petto-\(leaveData.id!)", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print("DEBUG_PRINT: NavigationBarHandler.registerLocalNotification end")
    }
    
    func onClick1() {
        self.viewController?.slideMenuController()?.openLeft()
    }
    func onClick2() {
        // アニメーション削除
        self.viewController?.navigationController?.view.layer.removeAllAnimations()
        
        let viewController2 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.viewController?.navigationController?.pushViewController(viewController2, animated: false)
    }
    func onClick3() {
        // ユーザープロフィールが未作成の場合
        if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            SVProgressHUD.showError(withStatus: "ユーザプロフィールを設定してください")
            // アニメーション削除
            self.viewController?.navigationController?.view.layer.removeAllAnimations()
            
            let viewController3 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            self.viewController?.navigationController?.pushViewController(viewController3, animated: false)
        }else{
            // アニメーション削除
            self.viewController?.navigationController?.view.layer.removeAllAnimations()
            
            let viewController3 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "TodoList") as! TodoListViewController
            self.viewController?.navigationController?.pushViewController(viewController3, animated: false)
        }
    }
    func onClick4() {
        // ユーザープロフィールが未作成の場合
        if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            SVProgressHUD.showError(withStatus: "ユーザプロフィールを設定してください")
            // アニメーション削除
            self.viewController?.navigationController?.view.layer.removeAllAnimations()
            
            let viewController3 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            self.viewController?.navigationController?.pushViewController(viewController3, animated: false)
        }else{
            // アニメーション削除
            self.viewController?.navigationController?.view.layer.removeAllAnimations()
            
            let viewController4 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "MessageList") as! MessageListViewController
            self.viewController?.navigationController?.pushViewController(viewController4, animated: false)
        }
    }
    func onClick5() {
        // アニメーション削除
        self.viewController?.navigationController?.view.layer.removeAllAnimations()
        
        let viewController5 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        self.viewController?.navigationController?.pushViewController(viewController5, animated: false)
    }
}

class BaseFormViewController: FormViewController {
    let helper = NavigationBarHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseFormViewController.viewDidLoad start")
        print("DEBUG_PRINT: BaseFormViewController.viewDidLoad end")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DEBUG_PRINT: BaseFormViewController.viewDidAppear start")
        
        // ログインしてないか、ユーザーデフォルトが消えてる場合
        if UserDefaults.standard.string(forKey: DefaultString.GuestFlag) == nil || FIRAuth.auth()?.currentUser == nil{
            // オブザーバーを削除する
            FIRDatabase.database().reference().removeAllObservers()
            // viewDidAppear内でpresent()を呼び出しても表示されないためメソッドが終了してから呼ばれるようにする
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        }else{
            // ナビゲーションバーを表示
            helper.viewController = self
            helper.setupNavigationBar()
        }
        print("DEBUG_PRINT: BaseFormViewController.viewDidAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: BaseFormViewController.viewWillDisappear start")
        
        if let _ = FIRAuth.auth()?.currentUser, !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag){
            for (k,v) in (self.helper.myUserData?.todoRoomIds)! {
                if v {
                    let ref = FIRDatabase.database().reference().child(Paths.LeavePath)
                    ref.child(k).removeAllObservers()
                }
            }
        }
        
        print("DEBUG_PRINT: BaseFormViewController.viewWillDisappear end")
    }
}

class BaseViewController: UIViewController {
    let helper = NavigationBarHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseViewController.viewDidLoad start")
        print("DEBUG_PRINT: BaseViewController.viewDidLoad end")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DEBUG_PRINT: BaseViewController.viewDidAppear start")
        
        // ログインしてないか、ユーザーデフォルトが消えてる場合
        if UserDefaults.standard.string(forKey: DefaultString.GuestFlag) == nil || FIRAuth.auth()?.currentUser == nil{
            // オブザーバーを削除する
            FIRDatabase.database().reference().removeAllObservers()
            // viewDidAppear内でpresent()を呼び出しても表示されないためメソッドが終了してから呼ばれるようにする
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
        }else{
            // ナビゲーションバーを表示
            helper.viewController = self
            helper.setupNavigationBar()
        }
        
        print("DEBUG_PRINT: BaseViewController.viewDidAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: BaseViewController.viewWillDisappear start")
        
        if let _ = FIRAuth.auth()?.currentUser, !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag){
            for (k,v) in (self.helper.myUserData?.todoRoomIds)! {
                if v {
                    let ref = FIRDatabase.database().reference().child(Paths.LeavePath)
                    ref.child(k).removeAllObservers()
                }
            }
        }
        
        print("DEBUG_PRINT: BaseViewController.viewWillDisappear end")
    }
}


