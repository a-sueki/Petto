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

class BaseViewController: UIViewController {

    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!

    // FIRDatabaseのobserveEventの登録状態を表す
//    var observing = false

    override func viewDidLoad() {
        super.viewDidLoad()

        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(self.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(self.onClick3))
        btn4 = UIBarButtonItem(image: UIImage(named: "mail"), style: .plain, target: self, action: #selector(self.onClick4))
        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(self.onClick5))
        
        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns

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
        let viewController3 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController3, animated: true)
    }
    func onClick4() {
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        self.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Entry") as! EntryViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }


}
