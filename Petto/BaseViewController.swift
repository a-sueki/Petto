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
import UIKit

class NavigationBarHandler: NSObject {
    
    var userDefaults: UserDefaults?
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
        
        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button1.setImage(UIImage(named: "menu"), for: .normal)
        button1.addTarget(self, action: #selector(onClick1), for: .touchUpInside)
        let button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 63, height: 25))
        button2.setImage(UIImage(named: "logo"), for: .normal)
        button2.addTarget(self, action: #selector(onClick2), for: .touchUpInside)
        let button3 = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button3.setImage(UIImage(named: "todolist"), for: .normal)
        button3.addTarget(self, action: #selector(onClick3), for: .touchUpInside)
        let button4 = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button4.setImage(UIImage(named: "mail"), for: .normal)
        button4.addTarget(self, action: #selector(onClick4), for: .touchUpInside)
        let button5 = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button5.setImage(UIImage(named: "search"), for: .normal)
        button5.addTarget(self, action: #selector(onClick5), for: .touchUpInside)
        
        // 未読メッセージリストをカウント
        self.userDefaults = UserDefaults.standard
        
        if let uid = self.userDefaults?.string(forKey: DefaultString.Uid) {
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
            // Userの未読リストを取得
            ref.observe(.value, with: { (snapshot) in
                print("DEBUG_PRINT: NavigationBarHandler.setupNavigationBar .valueイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    self.userData = UserData(snapshot: snapshot, myId: uid)
                    if self.userData?.unReadRoomIds.count != 0 {
                        // 通知バッチをセット
                        self.hub.setView(button4, andCount: Int32((self.userData?.unReadRoomIds.count)!))
                        // 設置するhubの背景色をredに文字色を白にする
                        self.hub.setCircleColor(UIColor.red, label: UIColor.white)
                        // バッチのサイズを変更
                        self.hub.scaleCircleSize(by: 0.8)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
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
        // アニメーション削除
        self.viewController?.navigationController?.view.layer.removeAllAnimations()
        
        let viewController4 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        self.viewController?.navigationController?.pushViewController(viewController4, animated: false)
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
        
        helper.viewController = self
        helper.setupNavigationBar()
        
        print("DEBUG_PRINT: BaseFormViewController.viewDidLoad end")
    }
    
}

class BaseViewController: UIViewController {
    let helper = NavigationBarHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseViewController.viewDidLoad start")
        
        helper.viewController = self
        helper.setupNavigationBar()
        
        print("DEBUG_PRINT: BaseViewController.viewDidLoad end")
    }
}


