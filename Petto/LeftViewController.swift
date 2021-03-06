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
import SVProgressHUD

enum LeftMenu: Int {
    case home = 0
    case post = 1
    case messages = 2
}

class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var mainViewController: UINavigationController!
    var menus = ["Account","Profile", "My Pet", "Message", "Oazuke / Azukari", "BlockList" , "How to Use","Contact Us","Privacy Policy"]
    var myUserData: UserData?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: LeftViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 0.5)
        
        print("DEBUG_PRINT: LeftViewController.viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: LeftViewController.viewWillAppear start")
    
        // 未読・未実施ハイライト
        if let user = Auth.auth().currentUser ,!UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
            let ref = Database.database().reference().child(Paths.UserPath)
            ref.child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: LeftViewController.viewWillAppear .observeSinleEventイベントが発生しました。")
                if let _ = snapshot.value {
                    self.myUserData = UserData(snapshot: snapshot, myId: user.uid)
                    // ユーザーデフォルト設定
                    UserDefaults.standard.set([String:Bool](), forKey: DefaultString.UnReadRoomIds)
                    if self.myUserData?.unReadRoomIds != nil && !(self.myUserData?.unReadRoomIds.isEmpty)! {
                        // ユーザーデフォルト設定
                        UserDefaults.standard.set(self.myUserData?.unReadRoomIds , forKey: DefaultString.UnReadRoomIds)
                    }
                    UserDefaults.standard.set([String:Bool](), forKey: DefaultString.TodoRoomIds)
                    if self.myUserData?.todoRoomIds != nil && !(self.myUserData?.todoRoomIds.isEmpty)! {
                        // ユーザーデフォルト設定
                        UserDefaults.standard.set(self.myUserData?.todoRoomIds , forKey: DefaultString.TodoRoomIds)
                    }
                    UserDefaults.standard.set([String:Bool](), forKey: DefaultString.RoomIds)
                    if self.myUserData?.roomIds != nil && !(self.myUserData?.roomIds.isEmpty)! {
                        // ユーザーデフォルト設定
                        UserDefaults.standard.set(self.myUserData?.roomIds , forKey: DefaultString.RoomIds)
                    }
                    self.tableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        } else {
            print("DEBUG_PRINT: LeftViewController.viewWillAppear ゲストユーザです。")
        }
        
        print("DEBUG_PRINT: LeftViewController.viewWillAppear end")
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: LeftViewController.cellForRowAt start")
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        // Cellに値を設定する.
        let menu = menus[indexPath.row]
        
        if indexPath.row == 3 {
            if UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds) != nil &&
                !(UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)?.isEmpty)! {
                cell.textLabel?.text = "\(menu) (\(UserDefaults.standard.dictionary(forKey: DefaultString.UnReadRoomIds)!.count))"
                cell.textLabel?.textColor = UIColor.red
            }else{
                cell.textLabel?.textColor = UIColor.darkText
                cell.textLabel?.text = menu
            }
        }else if indexPath.row == 4 {
            var count = 0
            if UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds) != nil &&
                !(UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)?.isEmpty)! {
                for (k,v) in UserDefaults.standard.dictionary(forKey: DefaultString.TodoRoomIds)! {
                    if v as! Bool{
                        print(k)
                        print(count)
                       count = count + 1
                    }
                }
            }
            if count != 0 {
                cell.textLabel?.text = "\(menu) (\(count))"
                cell.textLabel?.textColor = UIColor.red
            }else{
                cell.textLabel?.textColor = UIColor.darkText
                cell.textLabel?.text = menu
            }
/*        }else if indexPath.row == 5 {
            if UserDefaults.standard.object(forKey: DefaultString.BlockedPetIds) != nil ,!UserDefaults.standard.array(forKey: DefaultString.BlockedPetIds)!.isEmpty {
                print("DEBUG_PRINT: LeftViewController.cellForRowAt 1")
                print(UserDefaults.standard.array(forKey: DefaultString.BlockedPetIds))
                cell.textLabel?.textColor = UIColor.darkText
                cell.textLabel?.text = menu
            }else if UserDefaults.standard.object(forKey: DefaultString.BlockedUserIds) != nil ,!UserDefaults.standard.array(forKey: DefaultString.BlockedUserIds)!.isEmpty {
                print("DEBUG_PRINT: LeftViewController.cellForRowAt 2")
                print(UserDefaults.standard.array(forKey: DefaultString.BlockedUserIds))
                cell.textLabel?.textColor = UIColor.darkText
                cell.textLabel?.text = menu
            }else{
                print("DEBUG_PRINT: LeftViewController.cellForRowAt 3")
                print(UserDefaults.standard.array(forKey: DefaultString.BlockedPetIds))
                print(UserDefaults.standard.array(forKey: DefaultString.BlockedUserIds))
                cell.textLabel?.textColor = UIColor.lightGray
                cell.textLabel?.text = menu
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
 */
        }else {
            cell.textLabel?.textColor = UIColor.darkText
            cell.textLabel?.text = menu
        }
        
        print("DEBUG_PRINT: LeftViewController.cellForRowAt end")
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: LeftViewController.didSelectRowAt start")
        
        switch indexPath.row {
        case 0:
            let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! AccountViewController
            let navigationController = UINavigationController(rootViewController: accountViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 1:
            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UserViewController
            let navigationController = UINavigationController(rootViewController: userViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 2:
            // ユーザープロフィールが未作成の場合
            if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) || Auth.auth().currentUser == nil {
                let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! AccountViewController
                let navigationController = UINavigationController(rootViewController: accountViewController)
                self.slideMenuController()?.changeMainViewController(navigationController, close: true)
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "先にログインして下さい")
                SVProgressHUD.dismiss(withDelay: 3)
            }else{
                let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPetList") as! MyPetListViewController
                let navigationController = UINavigationController(rootViewController: postViewController)
                self.slideMenuController()?.changeMainViewController(navigationController, close: true)
            }
        case 3:
            // ユーザープロフィールが未作成の場合
            if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) || Auth.auth().currentUser == nil {
                let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! AccountViewController
                let navigationController = UINavigationController(rootViewController: accountViewController)
                self.slideMenuController()?.changeMainViewController(navigationController, close: true)
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "先にログインして下さい")
                SVProgressHUD.dismiss(withDelay: 3)
            }else{
                let messageListViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageList") as! MessageListViewController
                let navigationController = UINavigationController(rootViewController: messageListViewController)
                self.slideMenuController()?.changeMainViewController(navigationController, close: true)
            }
        case 4:
            // ユーザープロフィールが未作成の場合
            if UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) || Auth.auth().currentUser == nil {
                let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! AccountViewController
                let navigationController = UINavigationController(rootViewController: accountViewController)
                self.slideMenuController()?.changeMainViewController(navigationController, close: true)
                SVProgressHUD.show(RandomImage.getRandomImage(), status: "先にログインして下さい")
                SVProgressHUD.dismiss(withDelay: 3)
            }else{
                let todoListViewController = self.storyboard?.instantiateViewController(withIdentifier: "TodoList") as! TodoListViewController
                let navigationController = UINavigationController(rootViewController: todoListViewController)
                self.slideMenuController()?.changeMainViewController(navigationController, close: true)
            }
        case 5:
            let blockListViewController = self.storyboard?.instantiateViewController(withIdentifier: "BlockList") as! BlockListViewController
            let navigationController = UINavigationController(rootViewController: blockListViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 6:
            guard let url = URL(string: URLs.howToUseURL) else {
                return //be safe
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        case 7:
            let contactViewController = self.storyboard?.instantiateViewController(withIdentifier: "Contact") as! ContactViewController
            let navigationController = UINavigationController(rootViewController: contactViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        case 8:
            let policyViewController = self.storyboard?.instantiateViewController(withIdentifier: "Policy") as! PolicyViewController
            let navigationController = UINavigationController(rootViewController: policyViewController)
            self.slideMenuController()?.changeMainViewController(navigationController, close: true)
        default:
            break
        }
        self.slideMenuController()?.closeLeft()
        
        print("DEBUG_PRINT: LeftViewController.didSelectRowAt end")
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

