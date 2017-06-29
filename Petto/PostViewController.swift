//
//  PostViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class PostViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {

    var petImage: UIImage!
    
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaPickerView: UIPickerView!
    @IBOutlet weak var petImageView: UIImageView!
    
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
    
    //列数
    func numberOfComponents(in areaPickerView: UIPickerView) -> Int {
        return 1
    }
    //行数
    func pickerView(_ areaPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaList.count
    }
    //表示内容
    func pickerView(_ areaPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String? {
        return areaList[row]
    }
    //選択時
    func pickerView(_ areaPickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        areaLabel.text = areaList[row]
    }
}
