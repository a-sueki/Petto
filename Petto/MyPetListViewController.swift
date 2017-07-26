//
//  MyPetListViewController.swift
//  Petto
//
//  Created by admin on 2017/07/26.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class MyPetListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    // test用
    var petphotos = ["dog1", "dog2","dog3"]
    var petname = ["豆助1", "豆助2","豆助3"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "MyPetListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myPetListCell")
        tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petphotos.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let testCell = tableView.dequeueReusableCell(withIdentifier: "myPetListCell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let userImageView = testCell.contentView.viewWithTag(1) as? UIImageView
        userImageView?.image = UIImage(named: petphotos[(indexPath as NSIndexPath).row])
        // Tag番号を使ってLabelのインスタンス生成
        let userNameLabel = testCell.contentView.viewWithTag(2) as? UILabel
        userNameLabel?.text = petname[(indexPath as NSIndexPath).row]
        
        
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
