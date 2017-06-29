//
//  PostViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class PostViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {

    var petImage: UIImage!
    
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaPickerView: UIPickerView!
    @IBOutlet weak var petImageView: UIImageView!
    
    var areaList = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.title = "ペット登録"
        areaPickerView.dataSource = self
        areaPickerView.delegate = self
        
        // 受け取った画像をImageViewに設定する
        petImageView.image = petImage
        
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {

        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController4, animated: true)

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
        areaLabel.textColor = UIColor.black
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        // ImageViewから画像を取得する
        let imageData = UIImageJPEGRepresentation(petImageView.image!, 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        // postDataに必要な情報を取得しておく
        let time = NSDate.timeIntervalSinceReferenceDate
        let name = FIRAuth.auth()?.currentUser?.displayName
        
        // 辞書を作成してFirebaseに保存する
        let postRef = FIRDatabase.database().reference().child(Const.PostPath)
        let postData = ["area": areaLabel.text!, "image": imageString, "time": String(time), "name": name!]
        postRef.childByAutoId().setValue(postData)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
