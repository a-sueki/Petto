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
import FirebaseStorageUI
import SVProgressHUD


class UserDetailViewController: BaseFormViewController {
    
    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: UserDetailViewController.viewDidLoad start")
        
        // フォーム
        form +++
            Section() {
                if let key = self.userData?.id, !UserDefaults.standard.bool(forKey: DefaultString.GuestFlag) {
                    var header = HeaderFooterView<UserDetailViewNib>(.nibFile(name: "UserDetailHeader", bundle: nil))
                    header.onSetupView = { (view, section) -> () in
                        view.userImageView.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
                        
                        view.userImageView.alpha = 1;
                     }
                    $0.header = header
                }
            }
            
            //TODO: コミットメント＆小さなバッジ（メダル）
            <<< NameRow("firstname") {
                $0.title = "名"
                $0.value = self.userData?.firstname ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = UserSex.strings
                $0.value = self.userData?.sex ?? $0.options.last
                $0.disabled = true
            }
            <<< TextRow("area") {
                $0.title = "エリア"
                $0.value = self.userData?.area ?? nil
                $0.disabled = true
            }
            <<< TextRow("age") {
                $0.title = "年齢"
                $0.value = self.userData?.age ?? "秘密"
                $0.disabled = true
            }
            
            +++ Section()
            <<< SwitchRow("expectTo"){
                $0.title = "ペットをあずかりたい"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.ExpectTo)
                $0.disabled = true
            }
            +++ Section("あずかり環境（任意）"){
                $0.hidden = .function(["expectTo"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "expectTo")
                    return row.value ?? false == false
                })
            }
            <<< MultipleSelectorRow<String>("userEnvironments") {
                $0.title = "飼養環境"
                $0.options = Environment.strings
                if UserDefaults.standard.object(forKey: DefaultString.UserEnvironments) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.UserEnvironments)! {
                        if val as! Bool == true {
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
                $0.options = Tool.strings
                if UserDefaults.standard.object(forKey: DefaultString.UserTools) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.UserTools)!{
                        if val as! Bool == true {
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
                $0.title = "あずかりNGペット"
                $0.options = UserNGs.strings
                if UserDefaults.standard.object(forKey: DefaultString.UserNgs) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.UserNgs)! {
                        if val as! Bool == true {
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
            +++ Section()
            <<< SwitchRow("enterDetails"){
                $0.title = "より詳細なプロフィールを入力する"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.EnterDetails)
                $0.disabled = true
            }
            
            +++ Section("ペット経験など"){
                $0.hidden = .function(["enterDetails"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "enterDetails")
                    return row.value ?? false == false
                })
            }
            <<< CheckRow("hasAnotherPet") {
                $0.title = "現在、他にペットを飼っている"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.HasAnotherPet)
                $0.disabled = true
            }
            <<< CheckRow("isExperienced") {
                $0.title = "過去、ペットを飼った経験がある"
                $0.value = UserDefaults.standard.bool(forKey: DefaultString.IsExperienced)
                $0.disabled = true
            }
            //TODO: 「Bad評価1つ以上」は非表示。システムで判断する。
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "飼い主さんへの留意事項"
                $0.options = PetNGs.strings
                if UserDefaults.standard.object(forKey: DefaultString.Ngs) != nil {
                    var codes = [String]()
                    for (key,val) in UserDefaults.standard.dictionary(forKey: DefaultString.Ngs)! {
                        if val as! Bool == true {
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
            
            //TODO:Petto利用履歴
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "もどる"
                }.onCellSelection { [weak self] (cell, row) in
                    self?.back()
        }
        print("DEBUG_PRINT: UserDetailViewController.viewDidLoad end")
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
