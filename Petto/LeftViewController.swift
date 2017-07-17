//
//  LeftViewController.swift
//  Petto
//
//  Created by admin on 2017/06/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

enum LeftMenu: Int {
    case home = 0
    case post = 1
    case messages = 2
}

class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var mainViewController: UINavigationController!
    
    @IBOutlet weak var tableView: UITableView!
    
    var menus = ["ホーム", "ペット投稿","メッセージ","詳細","メッセージ一覧","Entry"]
    var homeViewController: UIViewController!
    var postViewController: UIViewController!
    var messagesViewController: UIViewController!
    var detailViewController: UIViewController!
    var messageListViewController: UIViewController!
    
    //    var imageHeaderView: ImageHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 0.5)
        
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        
        // Cellに値を設定する.
        let menu = menus[indexPath.row]
        cell.textLabel?.text = menu
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        switch indexPath.row {
        case 0:
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
            let navigationController = UINavigationController(rootViewController: homeViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 1:
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Entry") as! EntryViewController
            let navigationController = UINavigationController(rootViewController: postViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 2:
            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let navigationController = UINavigationController(rootViewController: messagesViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 3:
            let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "Entry") as! EntryViewController
            let navigationController = UINavigationController(rootViewController: detailViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 4:
            let messageListViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageList") as! MessageListViewController
            let navigationController = UINavigationController(rootViewController: messageListViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 5:
            let entryViewController = self.storyboard?.instantiateViewController(withIdentifier: "Entry") as! EntryViewController
            let navigationController = UINavigationController(rootViewController: entryViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        default:
            break
        }
        self.slideMenuController()?.closeLeft()
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
}

