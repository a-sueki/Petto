//
//  HomeViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

/*    var navController1: UINavigationController!
    var navController2: UINavigationController!
    var navController3: UINavigationController!
    var navController4: UINavigationController!
*/
    // ボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn1 = UIBarButtonItem(image: UIImage(named: "icons8-Menu.png"), style: .plain, target: self, action: #selector(HomeViewController.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo_small.png"), style: .plain, target: self, action: #selector(HomeViewController.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "icons8-Checked.png"), style: .plain, target: self, action: #selector(HomeViewController.onClick3))
        btn4 = UIBarButtonItem(image: UIImage(named: "icons8-Mailbox.png"), style: .plain, target: self, action: #selector(HomeViewController.onClick4))
        btn5 = UIBarButtonItem(image: UIImage(named: "icons8-Search.png"), style: .plain, target: self, action: #selector(HomeViewController.onClick5))

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
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }

}
