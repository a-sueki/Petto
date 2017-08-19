//
//  UserDetailViewController.swift
//  Petto
//
//  Created by admin on 2017/08/15.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD


class UserDetailViewController: FormViewController {
    
    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    // NavigationBarボタンを用意
    var btn1: UIBarButtonItem!
    var btn2: UIBarButtonItem!
    var btn3: UIBarButtonItem!
    var btn4: UIBarButtonItem!
    var btn5: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG_PRINT: UserDetailViewController.viewDidLoad start")
        
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
        
        //DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        // フォーム
        form +++
            Section() {
                if let _ = self.userData {
                   var header = HeaderFooterView<UserDetailViewNib>(.nibFile(name: "PetDetailHeader", bundle: nil))
                     header.onSetupView = { (view, section) -> () in
                        view.userImageView.image = self.userData!.image
                        
                        view.userImageView.alpha = 0;
                        UIView.animate(withDuration: 2.0, animations: { [weak view] in
                            view?.userImageView.alpha = 1
                        })
                        view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view] in
                            view?.layer.transform = CATransform3DIdentity
                        })
                    }
                    $0.header = header
                }
            }

            //TODO: コミットメント＆小さなバッチ（メダル）
            
            <<< AccountRow("displayName") {
                $0.title = "ニックネーム"
                $0.value = self.userData?.displayName ?? nil
                $0.disabled = true
            }
            <<< TextRow("area") {
                $0.title = "エリア"
                $0.value = self.userData?.area ?? nil
                $0.disabled = true
            }
            
            +++ Section("ペット経験")
            <<< CheckRow("hasAnotherPet") {
                $0.title = "現在、他にペットを飼っている"
                $0.value = self.userData?.hasAnotherPet ?? false
                $0.disabled = true
            }
            <<< CheckRow("isExperienced") {
                $0.title = "過去、ペットを飼った経験がある"
                $0.value = self.userData?.isExperienced ?? false
                $0.disabled = true
            }
            //TODO: 「Bad評価1つ以上」は非表示。システムで判断する。
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "注意事項"
                $0.options = PetNGs.strings
                if let data = self.userData , data.ngs.count > 0 {
                    let codes = Array(data.ngs.keys)
                    $0.value = PetNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            
            +++ Section()
            <<< SwitchRow("expectTo"){
                $0.title = "ペットをあずかりたい"
                $0.value = self.userData?.expectTo ?? false
                $0.disabled = true
            }
            
            +++ Section("あずかり環境"){
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
            }
            <<< MultipleSelectorRow<String>("userEnvironments") {
                $0.title = "飼養環境"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                //TODO:アイコン表示
                $0.options = Environment.strings
                if let data = self.userData , data.userEnvironments.count > 0 {
                    let codes = Array(data.userEnvironments.keys)
                    $0.value = Environment.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("userTools") {
                $0.title = "用意できる道具"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = Tool.strings
                if let data = self.userData , data.userTools.count > 0 {
                    let codes = Array(data.userTools.keys)
                    $0.value = Tool.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("userNgs") {
                $0.title = "NGペット"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = UserNGs.strings
                if let data = self.userData , data.userNgs.count > 0 {
                    let codes = Array(data.userNgs.keys)
                    $0.value = UserNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            //TODO:Petto利用履歴
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
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
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        self.navigationController?.pushViewController(viewController4, animated: true)
    }
    func onClick5() {
        let viewController5 = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        self.navigationController?.pushViewController(viewController5, animated: true)
    }
    
}

class UserDetailViewNib: UIView {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
