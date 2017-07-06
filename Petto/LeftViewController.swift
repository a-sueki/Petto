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
    
    var menus = ["ほーむ", "Post","Messages"]
    var homeViewController: UIViewController!
    var postViewController: UIViewController!
    var messagesViewController: UIViewController!
    //    var imageHeaderView: ImageHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.mainViewController = UINavigationController(rootViewController: homeViewController)
        
        let postViewController = storyboard.instantiateViewController(withIdentifier: "Post") as! PostViewController
        self.postViewController = UINavigationController(rootViewController: postViewController)
        
        //        self.tableView.registerCellClass(BaseTableViewCell.self)
        
        //        self.imageHeaderView = ImageHeaderView.loadNib()
        //        self.view.addSubview(self.imageHeaderView)
        
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
            
            //      self.navigationController?.pushViewController(homeViewController, animated: true)
        //dameja----n           present(self.navigationController!, animated: true, completion: nil)
        case 1:
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
            
            let navigationController = UINavigationController(rootViewController: postViewController)
            // self.navigationController?.pushViewController(postViewController, animated: true)
            //present(self.navigationController!, animated: true, completion: nil
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
            
        case 2:
            let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
            let navigationController = UINavigationController(rootViewController: messagesViewController)
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
    
    /*    func changeViewController(_ menu: LeftMenu) {
     switch menu {
     case .home:
     self.slideMenuController()?.changeMainViewController(self.homeViewController, close: true)
     case .post:
     self.slideMenuController()?.changeMainViewController(self.postViewController, close: true)
     case .messages:
     self.slideMenuController()?.changeMainViewController(self.messagesViewController, close: true)
     }
     }
     */
}
