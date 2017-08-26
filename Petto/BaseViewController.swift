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
import FirebaseDatabase
import RKNotificationHub
import UserNotifications

class BaseViewController: UIViewController {

    // RKNotificationHubのインスタンス
    let hub = RKNotificationHub()
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard

    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BaseViewController.viewDidLoad start")
        
        // 通知バッチを表示
        let button4 = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button4.setImage(UIImage(named: "mail"), for: .normal)
        button4.addTarget(self, action: #selector(self.onClick4), for: .touchUpInside)
        //  hubをhogeButtonに設置し、最初に表示させるバッジのCountを3にする
        hub.setView(button4, andCount: 3)
        //  設置するhubの背景色を黒に文字色を白にする
        hub.setCircleColor(UIColor.black, label: UIColor.white)

        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(self.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(self.onClick3))
        btn4 = UIBarButtonItem(customView: button4)
        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(self.onClick5))

        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns
        
        print("DEBUG_PRINT: BaseViewController.viewDidLoad end")
    }
    
/*    override func viewWillAppear(_ animated: Bool) {
        //var message = MessageData(snapshot: <#FIRDataSnapshot#>)
        //setNotification(message: message)
        setNotification(s: "aaaaa")
    }

    func setNotification(s: String) {
        print("DEBUG_PRINT: BaseViewController.setNotification start")
        let content = UNMutableNotificationContent()
        content.title = "たいとる"
        content.body = s
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date() as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
//        let tigger = UNPushNotificationTrigger
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String("xxx"), content: content, trigger: trigger)
        
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
        print("DEBUG_PRINT: BaseViewController.setNotification start")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
*/
    

    func onClick1() {
        self.slideMenuController()?.openLeft()
    }
    func onClick2() {
        let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    func onClick3() {
        let viewController3 = self.storyboard?.instantiateViewController(withIdentifier: "Leave") as! LeaveViewController
        self.navigationController?.pushViewController(viewController3, animated: true)
    }
    func onClick4() {
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        self.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }
}
