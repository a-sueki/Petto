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
    
    var userDefaults: UserDefaults?
    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    
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
        
        // 未読メッセージリストをカウント
        self.userDefaults = UserDefaults.standard
        
        
        if let user = FIRAuth.auth()?.currentUser {
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(user.uid)
            // HUDで処理中を表示
            SVProgressHUD.show()
            // Userの未読リストを取得
            ref.observe(.value, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar .valueイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    self.userData = UserData(snapshot: snapshot, myId: user.uid)
                    
                    // UserDefaultsを更新
                    self.userDefaults?.set(self.userData?.id, forKey: DefaultString.Uid)
                    self.userDefaults?.set(self.userData?.imageString , forKey: DefaultString.Phote)
                    self.userDefaults?.set(self.userData?.area , forKey: DefaultString.Area)
                    self.userDefaults?.set(self.userData?.firstname , forKey: DefaultString.DisplayName)
                    self.userDefaults?.set(self.userData?.age, forKey: DefaultString.Age)
                    //TODO: good,bad
                    
                    // 通知バッチの更新
                    if let count = self.userData?.unReadRoomIds.count ,count != 0 {
                        print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar 未読あり")
                        // 通知バッチをセット
                        self.hub.setView(button4, andCount: Int32((self.userData?.unReadRoomIds.count)!))
                        // 設置するhubの背景色をredに文字色を白にする
                        self.hub.setCircleColor(UIColor.red, label: UIColor.white)
                        // バッチのサイズを変更
                        self.hub.scaleCircleSize(by: 0.8)
                    }else{
                        print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar 未読なし")
                        // 通知バッチを消す
                        self.hub.setView(button4, andCount: -1)
                        // 設置するhubの背景色をredに文字色を白にする
                        self.hub.setCircleColor(UIColor.blue, label: UIColor.white)
                        // バッチのサイズを変更
                        self.hub.scaleCircleSize(by: 0.5)
                    }
                    // HUDを消す
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar ユーザはログインしていません")
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
        // アニメーション削除
        self.viewController?.navigationController?.view.layer.removeAllAnimations()
        
        let viewController3 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Leave") as! LeaveViewController
        self.viewController?.navigationController?.pushViewController(viewController3, animated: false)
    }
    func onClick4() {
        // ユーザープロフィールが未作成の場合
        if self.userDefaults?.string(forKey: "area") == nil {
            SVProgressHUD.showError(withStatus: "ユーザプロフィールを設定してください")
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
    var userDefaults: UserDefaults?
    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseFormViewController.viewDidLoad start")
        
        helper.viewController = self
        helper.setupNavigationBar()
        self.userData = helper.userData
        self.userDefaults = helper.userDefaults
        
        print("DEBUG_PRINT: BaseFormViewController.viewDidLoad end")
    }
    
}

class BaseViewController: UIViewController {
    let helper = NavigationBarHandler()
    var userDefaults: UserDefaults?
    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseViewController.viewDidLoad start")
        
        helper.viewController = self
        helper.setupNavigationBar()
        self.userData = helper.userData
        self.userDefaults = helper.userDefaults
        
        print("DEBUG_PRINT: BaseViewController.viewDidLoad end")
    }
}


