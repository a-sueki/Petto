//
//  BaseViewController.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Eureka
import RKNotificationHub
import UIKit

class NavigationBarHandler: NSObject {
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
        // 通知バッチを表示
        let button4 = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button4.setImage(UIImage(named: "mail"), for: .normal)
        button4.addTarget(self, action: #selector(onClick4), for: .touchUpInside)
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
        
        self.viewController?.navigationItem.leftBarButtonItems = leftBtns
        self.viewController?.navigationItem.rightBarButtonItems = rightBtns
    }
    
    func onClick1() {
        self.viewController?.slideMenuController()?.openLeft()
    }
    func onClick2() {
        let viewController2 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.viewController?.navigationController?.pushViewController(viewController2, animated: true)
    }
    func onClick3() {
        let viewController3 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Leave") as! LeaveViewController
        self.viewController?.navigationController?.pushViewController(viewController3, animated: true)
    }
    func onClick4() {
        let viewController4 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        self.viewController?.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        self.viewController?.navigationController?.pushViewController(viewController5, animated: true)
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


