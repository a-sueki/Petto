//
//  LeftViewController.swift
//  Petto
//
//  Created by admin on 2017/06/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


enum LeftMenu: Int {
    case home = 0
    case post = 1
    case messages = 2
}

class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false

    var mainViewController: UINavigationController!
    
    @IBOutlet weak var tableView: UITableView!
    
    var menus = ["UserProfile", "MyPetList","MessageList","Leave","UserDetail"]
/*    var homeViewController: UIViewController!
    var postViewController: UIViewController!
    var messagesViewController: UIViewController!
    var detailViewController: UIViewController!
    var messageListViewController: UIViewController!
*/
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
            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            let navigationController = UINavigationController(rootViewController: userViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 1:
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPetList") as! MyPetListViewController
            let navigationController = UINavigationController(rootViewController: postViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 2:
            let messageListViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageList") as! MessageListViewController
            let navigationController = UINavigationController(rootViewController: messageListViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 3:
            let leaveViewController = self.storyboard?.instantiateViewController(withIdentifier: "Leave") as! LeaveViewController
            let navigationController = UINavigationController(rootViewController: leaveViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 4://確認用
            let userDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailViewController
            let navigationController = UINavigationController(rootViewController: userDetailViewController)
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
        //self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    

}

