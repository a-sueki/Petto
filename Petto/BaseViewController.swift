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

        // UiView を バーボタンにセットして作成
        // UIButton をバーボタンに設定
        // UIButtonを作成
//        let view4 = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
//        let image4 = UIImageView(image: UIImage(named: "mail"))
//       view4.addSubview(image4)
        let button4 = UIButton()
        button4.setImage(UIImage(named: "mail"), for: .normal)
        button4.addTarget(self, action: #selector(self.onClick4), for: .touchUpInside)
//        view4.addSubview(button4)
        // ボタンタップ時のアクション設定
        //view.target(forAction: #selector(self.onClick4), withSender: self)
//        button.addTarget(self, action: #selector(self.onClick4), for:UIControlEvents.touchUpInside)
        // UIButton を バーボタンに設定
        //let btn4 : UIBarButtonItem = UIBarButtonItem(customView: button)

        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(self.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(self.onClick3))
//        btn4 = UIBarButtonItem(image: UIImage(named: "mail"), style: .plain, target: self, action: #selector(self.onClick4))
        btn4 = UIBarButtonItem(customView: button4)

        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(self.onClick5))

        
        

        
        
        //  hubをhogeButtonに設置し、最初に表示させるバッジのCountを3にする
        print("DEBUG_PRINT: BaseViewController.viewDidLoad 1")
//        hub.setView(view4, andCount: 3)
//        hub.setView(btn4, andCount: 3)
        //  設置するhubの背景色を黒に文字色を白にする
//        hub.setCircleColor(UIColor.black, label: UIColor.white)
        
        
        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns
        
        print("DEBUG_PRINT: BaseViewController.viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
