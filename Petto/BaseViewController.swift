//
//  BaseViewController.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Eureka
import RKNotificationHub
import Firebase
import FirebaseAuth
import SVProgressHUD
import UIKit

class NavigationBarHandler: NSObject {
    
    var userData: UserData?
    
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
        
        // ref作成
        let ref = FIRDatabase.database().reference().child(Paths.UserPath)
        
        // ユーザーデフォルト設定、通知バッチ更新
        if let user = FIRAuth.auth()?.currentUser, !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag){
           // 未読なしの場合のユーザーデフォルトの設定
            UserDefaults.standard.set([String:Bool]() , forKey: DefaultString.UnReadRoomIds)
            // UnReadRoomIds取得
            var unReadRoomIds = [String:Bool]()
            ref.child(user.uid).child("unReadRoomIds").observe(.childAdded, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar unReadRoomIds.childAddedイベントが発生しました。")
                if case _ as Bool = snapshot.value {
                    unReadRoomIds[snapshot.key] = true
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(unReadRoomIds , forKey: DefaultString.UnReadRoomIds)
                    if unReadRoomIds.count != 0 {
                        print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar 未読あり\(unReadRoomIds.count)")
                        // 通知バッチの更新
                        self.setNotificationBatch(button: button4, count: unReadRoomIds.count)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
            
            // todoRoomIds取得
            var todoRoomIds = [String:Bool]()
            ref.child(user.uid).child("todoRoomIds").observe(.childAdded, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar todoRoomIds.childAddedイベントが発生しました。")
                if case _ as Bool = snapshot.value {
                    todoRoomIds[snapshot.key] = true
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(todoRoomIds , forKey: DefaultString.TodoRoomIds)
                    if todoRoomIds.count != 0 {
                        print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar TODOあり\(todoRoomIds.count)")
                        // 通知バッチの更新
                        self.setNotificationBatch(button: button3, count: todoRoomIds.count)
                        //TODO: ローカル通知登録
                        
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
           }
            
            // roomIds取得
            var roomIds = [String:Bool]()
            ref.child(user.uid).child("roomIds").observe(.childAdded, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar roomIds.childAddedイベントが発生しました。")
                if case _ as Bool = snapshot.value {
                    roomIds[snapshot.key] = true
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(roomIds , forKey: DefaultString.RoomIds)
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
            
            // goods取得
/*            var goods = [String:Bool]()
            ref.child(user.uid).child("goods").observe(.childAdded, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar goods.childAddedイベントが発生しました。")
                if case _ as Bool = snapshot.value {
                    goods[snapshot.key] = true
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(goods , forKey: DefaultString.Goods)
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
            // bads取得
            var bads = [String:Bool]()
            ref.child(user.uid).child("bads").observe(.childAdded, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar bads.childAddedイベントが発生しました。")
                if case _ as Bool = snapshot.value {
                    bads[snapshot.key] = true
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set(bads , forKey: DefaultString.Bads)
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
 */
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
        print("DEBUG_PRINT: BaseFormViewController.viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        print("DEBUG_PRINT: BaseFormViewController.viewWillDisappear start")
        
        if let user = FIRAuth.auth()?.currentUser, !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag){
            let ref = FIRDatabase.database().reference().child(Paths.UserPath)
            ref.child(user.uid).child("unReadRoomIds").removeAllObservers()
            ref.child(user.uid).child("todoRoomIds").removeAllObservers()
            ref.child(user.uid).child("roomIds").removeAllObservers()
            ref.child(user.uid).child("goods").removeAllObservers()
            ref.child(user.uid).child("bads").removeAllObservers()
        }
        print("DEBUG_PRINT: BaseFormViewController.viewWillDisappear end")
    }
}

class BaseViewController: UIViewController {
    let helper = NavigationBarHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseViewController.viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        print("DEBUG_PRINT: BaseViewController.viewWillDisappear start")
        
        if let user = FIRAuth.auth()?.currentUser, !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag){
            let ref = FIRDatabase.database().reference().child(Paths.UserPath)
            ref.child(user.uid).child("unReadRoomIds").removeAllObservers()
            ref.child(user.uid).child("todoRoomIds").removeAllObservers()
            ref.child(user.uid).child("roomIds").removeAllObservers()
            ref.child(user.uid).child("goods").removeAllObservers()
            ref.child(user.uid).child("bads").removeAllObservers()
        }
        print("DEBUG_PRINT: BaseViewController.viewWillDisappear end")
    }

}


