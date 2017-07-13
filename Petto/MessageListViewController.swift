//
//  MessageListViewController.swift
//  Petto
//
//  Created by admin on 2017/07/07.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
class MessageListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // test用
    var photos = ["user", "user","user"]
    var username = ["taro", "hanako","jiro"]
    var goodInt = ["999", "3","20"]
    var badInt = ["999", "3","888"]
    var area = ["神奈川県", "神奈川県","神奈川県"]
    var timestamp = ["2017/07/09 11:11", "2017/07/09 11:11","2017/07/09 11:11"]
    var text = ["test1test1test1test1test1test1test1test1test1test1test1test1test1",
                "こんにちは！豆助かわいすぎです。ぜひあずからせてください！！！",
                "aaa"]

    var petphotos = ["dog1", "dog2","dog3"]
    var petname = ["豆助1", "豆助2","豆助3"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MessageListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "messageListCell")
        tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let testCell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let userImageView = testCell.contentView.viewWithTag(1) as? UIImageView
        userImageView?.image = UIImage(named: photos[(indexPath as NSIndexPath).row])
        // Tag番号を使ってLabelのインスタンス生成
        let userNameLabel = testCell.contentView.viewWithTag(2) as? UILabel
        userNameLabel?.text = username[(indexPath as NSIndexPath).row]
        // Tag番号を使ってLabelのインスタンス生成
        let goodIntLabel = testCell.contentView.viewWithTag(3) as? UILabel
        goodIntLabel?.text = goodInt[(indexPath as NSIndexPath).row]
        // Tag番号を使ってLabelのインスタンス生成
        let badIntLabel = testCell.contentView.viewWithTag(4) as? UILabel
        badIntLabel?.text = badInt[(indexPath as NSIndexPath).row]
        // Tag番号を使ってLabelのインスタンス生成
        let userAreaLabel = testCell.contentView.viewWithTag(5) as? UILabel
        userAreaLabel?.text = area[(indexPath as NSIndexPath).row]
        // Tag番号を使ってLabelのインスタンス生成
        let sendTimeLabel = testCell.contentView.viewWithTag(6) as? UILabel
        sendTimeLabel?.text = timestamp[(indexPath as NSIndexPath).row]
        // Tag番号を使ってLabelのインスタンス生成
        let messageLabel = testCell.contentView.viewWithTag(7) as? UILabel
        var mtext = text[(indexPath as NSIndexPath).row]
        print("mtext: \(mtext.characters.count)")
        if mtext.characters.count > 10 {
            mtext = mtext.substring(to: mtext.index(mtext.startIndex, offsetBy: 9)) + "..."
            print("mtext: \(mtext)")
            print("mtext: \(mtext.characters.count)")
        }
        messageLabel?.text = mtext
        // Tag番号を使ってImageViewのインスタンス生成
        let petImageView = testCell.contentView.viewWithTag(8) as? UIImageView
        petImageView?.image = UIImage(named: petphotos[(indexPath as NSIndexPath).row])
        // Tag番号を使ってLabelのインスタンス生成
        let petNameLabel = testCell.contentView.viewWithTag(9) as? UILabel
        petNameLabel?.text = petname[(indexPath as NSIndexPath).row]

        
        return testCell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }

}
