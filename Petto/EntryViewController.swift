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
                $0.title = "写真"
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
            
            +++ Section("requirement")
            <<< SwitchRow("あずかり人を募集する"){
                $0.title = $0.tag
            }
            <<< ButtonRow("おあずけ条件設定") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "ListSectionsControllerSegue", onDismiss: nil)
            }

/*
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
        
            for option in oceans {
                form.last! <<< ImageCheckRow<String>(option){ lrow in
                    lrow.title = option
                    lrow.selectableValue = option
                    lrow.value = nil
                    }.cellSetup { cell, _ in
                        cell.trueImage = UIImage(named: "checked-yellow")!
                        cell.falseImage = UIImage(named: "unchecked")!
                        cell.accessoryType = .checkmark
                }
            }
 */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class ListSectionsController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
/*        let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView(title: "Where do you live?")
        }
        
        for option in continents {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }
        }
*/
        
        let environments = ["室内のみ", "エアコンあり", "専有面積30㎡以上","2部屋以上"]
        form +++ SelectableSection<ImageCheckRow<String>>("飼養環境", selectionType: .multipleSelection)
        for option in environments {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
                }.cellSetup { cell, _ in
                    cell.trueImage = UIImage(named: "checked-yellow")!
                    cell.falseImage = UIImage(named: "unchecked")!
                    cell.accessoryType = .checkmark
            }
        }
        
        let tools = ["ペット用ベッド", "ペット用トイレ", "首輪＆リード", "ケージ（柵）" , "キャットタワー", "爪とぎ"]
        form +++ SelectableSection<ImageCheckRow<String>>("必要な道具", selectionType: .multipleSelection)
        for option in tools {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
                }.cellSetup { cell, _ in
                    cell.trueImage = UIImage(named: "checked-yellow")!
                    cell.falseImage = UIImage(named: "unchecked")!
                    cell.accessoryType = .checkmark
            }
        }
        
        let ngs = ["Bad評価1以上", "定時帰宅できない", "一人暮らし", "小児と同居" , "高齢者と同居"]
        form +++ SelectableSection<ImageCheckRow<String>>("あずかり人NG条件", selectionType: .multipleSelection)
        for option in ngs {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
                }.cellSetup { cell, _ in
                    cell.trueImage = UIImage(named: "checked-yellow")!
                    cell.falseImage = UIImage(named: "unchecked")!
                    cell.accessoryType = .checkmark
            }
        }
        
        //TODO: 餌やりのタイミング
        //TODO: 歯磨きのタイミング
        //TODO: 散歩のタイミング
        //TODO: おあずけ可能期間


    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
/*        if row.section === form[0] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue ?? "No row selected")")
        }
        else if row.section === form[1] {
            print("Mutiple Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue}))")
        }
         */
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
