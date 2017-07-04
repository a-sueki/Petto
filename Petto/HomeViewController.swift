//
//  HomeViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    

    // サムネイル画像のタイトル
    let photos = ["dog1", "dog2","dog3","cat1","cat2","cat3","cat4","cat5","cat6","cat7"]
    let kinds = ["dog-lightgray", "dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray","dog-lightgray"]
    let sexs = ["male-lightgray", "male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray","male-lightgray"]
    let areas = ["東京都", "東京都","神奈川県","神奈川県","神奈川県","東京都","東京都","神奈川県","静岡県","沖縄県"]
    let terms = ["期間：1~30 days", "期間：7 days","期間：3 days","期間：10 days","期間：1 day","期間：1 days","期間：29 days","期間：14~30 days","期間：14~30 days","期間：14~30 days"]
    
    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn1 = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(HomeViewController.onClick1))
        btn2 = UIBarButtonItem(image: UIImage(named: "logo"), style: .plain, target: self, action: #selector(HomeViewController.onClick2))
        btn3 = UIBarButtonItem(image: UIImage(named: "todolist"), style: .plain, target: self, action: #selector(HomeViewController.onClick3))
        btn4 = UIBarButtonItem(image: UIImage(named: "mail"), style: .plain, target: self, action: #selector(HomeViewController.onClick4))
        btn5 = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(HomeViewController.onClick5))

        let leftBtns: [UIBarButtonItem] = [btn1,btn2]
        let rightBtns: [UIBarButtonItem] = [btn3,btn4,btn5]
        
        self.navigationItem.leftBarButtonItems = leftBtns
        self.navigationItem.rightBarButtonItems = rightBtns

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Cell はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: photos[(indexPath as NSIndexPath).row])
        
        // Tag番号を使ってImageViewのインスタンス生成
        let kindImageView = testCell.contentView.viewWithTag(2) as! UIImageView
        kindImageView.image = UIImage(named: kinds[(indexPath as NSIndexPath).row])

        // Tag番号を使ってImageViewのインスタンス生成
        let sexImageView = testCell.contentView.viewWithTag(3) as! UIImageView
        sexImageView.image = UIImage(named: sexs[(indexPath as NSIndexPath).row])

        // Tag番号を使ってLabelのインスタンス生成
        let arealabel = testCell.contentView.viewWithTag(4) as! UILabel
        arealabel.text = areas[(indexPath as NSIndexPath).row]

        // Tag番号を使ってLabelのインスタンス生成
        let termlabel = testCell.contentView.viewWithTag(5) as! UILabel
        termlabel.text = terms[(indexPath as NSIndexPath).row]

        return testCell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2-2
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize*1.4141)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return 10;
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
