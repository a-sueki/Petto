//
//  PostViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class PostViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaPickerView: UIPickerView!
    
    var areaList = ["森永アイス　ラムネバー　ソーダ味","森永アイス　ラムネバー　白桃ソーダ味","赤城乳業ミント","森永Pinoバニラ","森永Pinoアーモンド","森永Pinoチョコ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        areaPickerView.dataSource = self
        areaPickerView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //PicerViewの列数は1とする
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    //PickerViewの行数は配列数にする
    func pickerView(_ areaPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaList.count
    }
    //PickerViewに表示する文字列を指定する
    func pickerView(areaPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaList.count
    }
    //PickerViewに表示する配列の要素数を設定する
    func pickerView(areaPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String! {
        return areaList[row]
    }
    //ラベル表示
    func pickerView(areaPickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        areaLabel.text = areaList[row]
    }
}
