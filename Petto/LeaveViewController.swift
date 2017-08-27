//
//  LeaveViewController.swift
//  Petto
//
//  Created by admin on 2017/08/09.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD

class LeaveViewController: BaseFormViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {

    
    var petData: PetData?
    var userData: UserData?
    var conditionArray = [String : Bool]()

    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var conditionsCollectionView: UICollectionView!
    @IBOutlet weak var checkListTableView: UITableView!
    

    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        conditionsCollectionView.delegate = self
        conditionsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "ConditionsCollectionViewCell", bundle: nil)
        conditionsCollectionView.register(nib, forCellWithReuseIdentifier: "ConditionsCell")
        
        // pet情報を取得
        // user情報を取得
        
        
    }
    
    @IBAction func toPetDetailButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.toPetDetailButton start")
        
        // PetDetailに画面遷移
        let petDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetDetail") as! PetDetailViewController
        petDetailViewController.petData = self.petData
        self.navigationController?.pushViewController(petDetailViewController, animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.toPetDetailButton end")
    }
    
    @IBAction func toUserDetailButton(_ sender: Any) {
        print("DEBUG_PRINT: LeaveViewController.toUserDetailButton start")
        
        // UserDetailに画面遷移
        let userDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailViewController
        userDetailViewController.userData = self.userData
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
        
        print("DEBUG_PRINT: LeaveViewController.toUserDetailButton end")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConditionsCell", for: indexPath) as! ConditionsCollectionViewCell
        
        //TODO:UserとPetどちらか一方がtrueの場合、red ->true
        //cell.setPetData(key: String, codeList: <#T##[String]#>)
        //cell.setPetData(text: conditionsString[indexPath.row], red: false)
        return cell
        
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2-2
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return 1//TODO: conditionArray.count
    }

    
    //TODO: 対面チェックリストで、連絡先、住所の交換を推奨する
}

