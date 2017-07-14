//
//  EntryViewController.swift
//  Petto
//
//  Created by admin on 2017/07/14.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka


class EntryViewController: FormViewController  {
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }

        form +++
            Section() {
//                $0.header = HeaderFooterView<PettoLogoView>(.class)
                var header = HeaderFooterView<PettoLogoViewNib>(.nibFile(name: "EntrySectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 0;
                    UIView.animate(withDuration: 2.0, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                    })
                }
                $0.header = header
            }
            
            <<< ImageRow(){
                $0.title = "ImageRow"
            }
            <<< NameRow() {
                $0.title = "ペットの名前"
                $0.placeholder = "ポチ"
            }
            <<< PickerInputRow<String>("areaPiker"){
                $0.title = "エリア"
                $0.options = []
                for i in 1...10{
                    $0.options.append("エリア \(i)")
                }
                $0.value = $0.options.first
            }

            +++ Section("Profile")
            <<< SegmentedRow<String>() {
                $0.title =  "性別"
                $0.options = ["♂", "♀"]
            }
            <<< SegmentedRow<String>() {
                $0.title =  "種類"
                $0.options = ["イヌ", "ネコ"]
            }
            <<< PickerInputRow<String>("categoryPicker"){
                $0.title = "カテゴリ"
                $0.options = []
                for i in 1...10{
                    $0.options.append("category \(i)")
                }
                $0.value = $0.options.first
            }
            <<< PickerInputRow<String>("agePicker"){
                $0.title = "年齢"
                $0.options = []
                for i in 1...10{
                    $0.options.append("age \(i)")
                }
                $0.value = $0.options.first
            }

            +++ Section("Condition")
            <<< CheckRow() {
                $0.title = "ワクチン接種"
                $0.value = true
            }
            <<< CheckRow() {
                $0.title = "去勢"
                $0.value = true
            }
            <<< CheckRow() {
                $0.title = "里親募集中"
                $0.value = true
            }
            
            +++ Section("おあずけ条件")
            <<< SwitchRow("Show Next Row"){
                $0.title = $0.tag
            }
            <<< SwitchRow("Show Next Section"){
                $0.title = $0.tag
                $0.hidden = .function(["Show Next Row"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Row")
                    return row.value ?? false == false
                })
            }
            
            +++ Section(footer: "This section is shown only when 'Show Next Row' switch is enabled"){
                $0.hidden = .function(["Show Next Section"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Section")
                    return row.value ?? false == false
                })
            }
            <<< TextRow() {
                $0.placeholder = "Gonna dissapear soon!!"
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


//MARK: Navigation Accessory View Example

class NavigationAccessoryController : FormViewController {
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions
        
        form = Section(header: "Settings", footer: "These settings change how the navigation accessory view behaves")
            
            <<< SwitchRow("set_none") { [weak self] in
                $0.title = "おあずけ条件を設定する"
                $0.value = self?.navigationOptions != .Disabled
                }.onChange { [weak self] in
                    if $0.value ?? false {
                        self?.navigationOptions = self?.navigationOptionsBackup
                        self?.form.rowBy(tag: "set_disabled")?.baseValue = self?.navigationOptions?.contains(.StopDisabledRow)
                        self?.form.rowBy(tag: "set_skip")?.baseValue = self?.navigationOptions?.contains(.SkipCanNotBecomeFirstResponderRow)
                        self?.form.rowBy(tag: "set_disabled")?.updateCell()
                        self?.form.rowBy(tag: "set_skip")?.updateCell()
                    }
                    else {
                        self?.navigationOptionsBackup = self?.navigationOptions
                        self?.navigationOptions = .Disabled
                    }
            }
            
            <<< CheckRow("set_disabled") { [weak self] in
                $0.title = "Stop at disabled row"
                $0.value = self?.navigationOptions?.contains(.StopDisabledRow)
                $0.hidden = "$set_none == false" // .Predicate(NSPredicate(format: "$set_none == false"))
                }.onChange { [weak self] row in
                    if row.value ?? false {
                        self?.navigationOptions = self?.navigationOptions?.union(.StopDisabledRow)
                    }
                    else{
                        self?.navigationOptions = self?.navigationOptions?.subtracting(.StopDisabledRow)
                    }
            }
            
            <<< CheckRow("set_skip") { [weak self] in
                $0.title = "Skip non first responder view"
                $0.value = self?.navigationOptions?.contains(.SkipCanNotBecomeFirstResponderRow)
                $0.hidden = "$set_none  == false"
                }.onChange { [weak self] row in
                    if row.value ?? false {
                        self?.navigationOptions = self?.navigationOptions?.union(.SkipCanNotBecomeFirstResponderRow)
                    }
                    else{
                        self?.navigationOptions = self?.navigationOptions?.subtracting(.SkipCanNotBecomeFirstResponderRow)
                    }
            }
            +++
            Section()
            
            <<< PhoneRow() { $0.title = "Your phone number" }
            
            <<< URLRow() {
                $0.title = "Disabled"
                $0.disabled = true
            }
            
            <<< TextRow() { $0.title = "Your father's name"}
            
            <<< TextRow(){ $0.title = "Your mother's name"}

    }
}



class PettoLogoViewNib: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class PettoLogoView: UIView {
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "catFootptint_orenge"))
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
