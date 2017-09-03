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


class UserDetailViewController: BaseFormViewController {
    
    var uid: String?
    //    var userData: UserData?
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: UserDetailViewController.viewDidLoad start")
        
        // Firebaseから登録済みデータを取得
        if uid != nil {
            // 要素が追加されたら再表示
            let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid!)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: UserDetailViewController.viewDidLoad .observeSingleEventイベントが発生しました。")
                
                self.userData = UserData(snapshot: snapshot, myId: self.uid!)
                
                // Formを表示
                self.updateUserData()
            })
            // FIRDatabaseのobserveEventが上記コードにより登録されたため
            // trueとする
            observing = true
        }
        
        print("DEBUG_PRINT: UserDetailViewController.viewDidLoad end")
    }
    
    func updateUserData() {
        print("DEBUG_PRINT: UserDetailViewController.updateUserData start")
        
        // フォーム
        form +++
            Section() {
                if let _ = self.userData {
                    var header = HeaderFooterView<UserDetailViewNib>(.nibFile(name: "UserDetailHeader", bundle: nil))
                    header.onSetupView = { (view, section) -> () in
                        view.userImageView.image = self.userData!.image
                        
                        view.userImageView.alpha = 1;
/*                        UIView.animate(withDuration: 2.0, animations: { [weak view] in
                            view?.userImageView.alpha = 1
                        })
                        view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view] in
                            view?.layer.transform = CATransform3DIdentity
                        })
 */
                    }
                    $0.header = header
                }
            }
            
            //TODO: コミットメント＆小さなバッチ（メダル）
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
                $0.title = "飼い主さんへの留意事項"
                $0.options = PetNGs.strings
                if let data = self.userData , data.ngs.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.ngs {
                        if val == true {
                            codes.append(key)
                        }
                    }
                    $0.value = PetNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
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
                $0.options = Environment.strings
                if let data = self.userData , data.userEnvironments.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.userEnvironments {
                        if val == true {
                            codes.append(key)
                        }
                    }
                    $0.value = Environment.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
            }
            <<< MultipleSelectorRow<String>("userTools") {
                $0.title = "用意できる道具"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = Tool.strings
                if let data = self.userData , data.userTools.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.userTools {
                        if val == true {
                            codes.append(key)
                        }
                    }
                    $0.value = Tool.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
            }
            <<< MultipleSelectorRow<String>("userNgs") {
                $0.title = "NGペット"
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
                $0.options = UserNGs.strings
                if let data = self.userData , data.userNgs.count > 0 {
                    var codes = [String]()
                    for (key,val) in data.userNgs {
                        if val == true {
                            codes.append(key)
                        }
                    }
                    $0.value = UserNGs.convertList(codes)
                }else{
                    $0.value = []
                }
                }
                .onPresent { from, to in
                    let _ = to.view
                    to.tableView?.isUserInteractionEnabled = false
            }
            //TODO:Petto利用履歴
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "もどる"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.back()
        }
        print("DEBUG_PRINT: UserDetailViewController.updateUserData end")
    }
    
    @IBAction func back() {
        print("DEBUG_PRINT: UserDetailViewController.back start")
        
        //前画面に戻る
        self.navigationController?.popViewController(animated: true)
        
        print("DEBUG_PRINT: UserDetailViewController.back end")
    }
    
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class UserDetailViewNib: UIView {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
