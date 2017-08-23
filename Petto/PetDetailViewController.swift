//
//  PetDetailViewController.swift
//  Petto
//
//  Created by admin on 2017/08/14.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import UIKit
import Eureka
import Firebase
import FirebaseDatabase
import SVProgressHUD


class PetDetailViewController: FormViewController {
    
    let userDefaults = UserDefaults.standard
    var petData: PetData?
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
        
        
        // Cell初期設定
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        //DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        
        // フォーム
        form +++
            Section() {
                if let _ = self.petData {
                    var header = HeaderFooterView<PetDetailViewNib>(.nibFile(name: "PetDetailHeader", bundle: nil))
                    header.onSetupView = { (view, section) -> () in
                        view.petImageView.image = self.petData!.image
                        
                        view.petImageView.alpha = 0;
                        UIView.animate(withDuration: 2.0, animations: { [weak view] in
                            view?.petImageView.alpha = 1
                        })
                        view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view] in
                            view?.layer.transform = CATransform3DIdentity
                        })
                    }
                    $0.header = header
                }
            }
            <<< NameRow("name") {
                $0.title = "名前"
                $0.value = self.petData?.name ?? nil
                $0.disabled = true
            }
            <<< PickerInputRow<String>("area"){
                $0.title = "エリア"
                $0.value = self.petData?.area ?? nil
                $0.disabled = true
            }

            +++ Section("プロフィール")
            <<< SegmentedRow<String>("sex") {
                $0.title =  "性別"
                $0.options = Sex.strings
                $0.value = self.petData?.sex ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("kind") {
                $0.title =  "種類"
                $0.options = Kind.strings
                $0.value = self.petData?.kind ?? nil
                $0.disabled = true
            }
            <<< PickerInputRow<String>("category"){
                $0.title = "品種"
                $0.value = self.petData?.category ?? nil
                $0.disabled = true
            }
            <<< PickerInputRow<String>("age"){
                $0.title = "年齢"
                $0.value = self.petData?.age ?? $0.options.first
                $0.disabled = true
            }
            
            +++ Section("状態")
            <<< CheckRow("isVaccinated") {
                $0.title = "ワクチン接種済み"
                $0.value = self.petData?.isVaccinated ?? false
                $0.disabled = true
            }
            <<< CheckRow("isCastrated") {
                $0.title = "去勢/避妊手術済み"
                $0.value = self.petData?.isCastrated ?? false
                $0.disabled = true
            }
            <<< CheckRow("wanted") {
                $0.title = "里親募集中"
                $0.value = self.petData?.wanted ?? false
                $0.disabled = true
            }
            <<< MultipleSelectorRow<String>("userNgs") {
                $0.title = "注意事項"
                $0.options = UserNGs.strings
                if let data = self.petData , data.userNgs.count > 0 {
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
            
            
            +++ Section()
            <<< SwitchRow("isAvailable"){
                $0.title = "あずかり人を募集する"
                $0.value = self.petData?.isAvailable ?? false
                $0.disabled = true
            }
            
            +++ Section("おあずけ条件"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< MultipleSelectorRow<String>("environments") {
                $0.title = "飼養環境"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                $0.options = Environment.strings
                if let data = self.petData , data.environments.count > 0 {
                    let codes = Array(data.environments.keys)
                    $0.value = Environment.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            
            <<< MultipleSelectorRow<String>("tools") {
                $0.title = "必要な道具"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                //TODO:アイコン表示
                $0.options = Tool.strings
                if let data = self.petData , data.tools.count > 0 {
                    let codes = Array(data.tools.keys)
                    $0.value = Tool.convertList(codes)
                }else{
                    $0.value = []
                }
                $0.disabled = true
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("ngs") {
                $0.title = "NGユーザ"
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
                $0.options = PetNGs.strings
                if let data = self.petData , data.ngs.count > 0 {
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
            
            
            +++ Section("お世話の方法"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< SegmentedRow<String>("feeding"){
                $0.title =  "ごはんの回数/日"
                $0.options = ["1回","2回","3回"]
                $0.value = self.petData?.feeding ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("dentifrice") {
                $0.title = "歯磨きの回数/日"
                $0.options = ["1回","2回","3回"]
                $0.value = self.petData?.dentifrice ?? nil
                $0.disabled = true
            }
            <<< SegmentedRow<String>("walk") {
                $0.title = "お散歩の回数/日"
                $0.options = ["不要","1回","2回"]
                $0.value = self.petData?.walk ?? nil
                $0.disabled = true
            }
            +++
            Section("おあずけ可能期間"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< DateRow("startDate") {
                if let dateString = self.petData?.startDate {
                    $0.value = dateFormatter.date(from: dateString)
                }else{
                    $0.value = Date()
                }
                $0.title = "開始日付"
                $0.disabled = true
            }
            <<< DateRow("endDate") {
                if let dateString = self.petData?.endDate {
                    $0.value = dateFormatter.date(from: dateString)
                }else{
                    $0.value = NSDate(timeInterval: 60*60*24*30, since: Date()) as Date
                }
                $0.title = "終了日付"
                $0.disabled = true
            }
            +++
            Section("連続おあずけ日数"){
                $0.hidden = .function(["isAvailable"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "isAvailable")
                    return row.value ?? false == false
                })
            }
            <<< PickerInputRow<Int>("minDays"){
                $0.title = "最短"
                $0.value = self.petData?.minDays ?? 1
                $0.disabled = true
            }
            <<< PickerInputRow<Int>("maxDays"){
                $0.title = "最長"
                $0.value = self.petData?.maxDays ?? 30
                $0.disabled = true
            }
            //TODO: その他、特記事項入力フォーム
            
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "飼い主にメッセージを送る"
                }.onCellSelection { [weak self] (cell, row) in
                    row.section?.form?.validate()
                    self?.toMessages()
        }
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toMessages() {
        // Messageに画面遷移
        let messagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesViewController
        
        messagesViewController.uid = userDefaults.string(forKey: DefaultString.Uid)!
        messagesViewController.userImageString = userDefaults.string(forKey: DefaultString.Phote)!
        messagesViewController.pid = (self.petData?.id)!
        messagesViewController.petImageString = (self.petData?.imageString)!
        //messagesViewController.petData = self.petData
        self.navigationController?.pushViewController(messagesViewController, animated: true)
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

class PetDetailViewNib: UIView {
    
    @IBOutlet weak var petImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

