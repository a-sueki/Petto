//
//  TestNavigationController.swift
//  Petto
//
//  Created by admin on 2017/06/23.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class TestNavigationController: UINavigationController, UINavigationControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート先に自分を設定する。
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //画面遷移後の呼び出しメソッド
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        //ナビゲーションアイテムのタイトルに画像を設定する。
        self.navigationBar.topItem!.titleView = UIImageView(image:UIImage(named: "logo.png"))
        
        //        navigationItem.titleView?.sizeToFit()
        
        //前画面ボタンとトップ画面ボタンの2つを設定する。
        let menu = UIImage(named: "icons8-Menu.png")
        
        let leftButton = UIBarButtonItem(image: menu, style: UIBarButtonItemStyle.plain, target: self, action:#selector(goMenu(sender:event:)))
        
        self.navigationItem.leftBarButtonItems = [leftButton]
        
        /*        let leftButton2 = UIBarButtonItem(title: "トップ画面", style: UIBarButtonItemStyle.Plain, target: self, action: "goTop")
         self.navigationItem.leftBarButtonItems = [leftButton1, leftButton2]
         */
        
        //ナビゲーションバーの高さを設定する。
        self.navigationBar.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height:80)
        
    }
    
    //トップに戻るボタン押下時の呼び出しメソッド
    func goMenu(sender: UIBarButtonItem, event:UIEvent) {
        
        //トップ画面に戻る。
        self.navigationController?.popToRootViewController(animated: true)
    }
    

}
