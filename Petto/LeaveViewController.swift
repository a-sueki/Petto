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

class LeaveViewController: FormViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {

    var petData: PetData?
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var feedingLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var conditionsCollectionView: UICollectionView!
    @IBOutlet weak var checkListTableView: UITableView!
    

    // FIRDatabaseのobserveEventの登録状態を表す
    //var observing = false
    
    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // NavigationBar
        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(BaseViewController.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(BaseViewController.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(BaseViewController.onClick3))
        btn4 = UIBarButtonItem(image: UIImage(named: "mail"), style: .plain, target: self, action: #selector(BaseViewController.onClick4))
        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(BaseViewController.onClick5))
        
        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns
        
        conditionsCollectionView.delegate = self
        conditionsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "ConditionsCollectionViewCell", bundle: nil)
        conditionsCollectionView.register(nib, forCellWithReuseIdentifier: "ConditionsCell")
        
        
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
        return 1//petData.count
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
/*    func handleLikeButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.conditionsCollectionView)
        let indexPath = conditionsCollectionView.indexPathForItem(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        //let petData = self.petData[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if petData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in petData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = petData.likes.index(of: likeId)!
                        break
                    }
                }
                petData.likes.remove(at: index)
            } else {
                petData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = FIRDatabase.database().reference().child(Paths.PetPath).child(petData.id!)
            let likes = ["likes": petData.likes]
            postRef.updateChildValues(likes)
        }
 

    }
    */
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
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }
}

