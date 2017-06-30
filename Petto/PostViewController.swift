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

class PostViewController: UIViewController , PopUpPickerViewDelegate{

    var petImage: UIImage!
/*    var kindPickerView: PopUpPickerView!
    var areaPickerView: PopUpPickerView!
    var agePickerView: PopUpPickerView!
*/
    var pickerView: PopUpPickerView!

    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    
    var areaList = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]

    var dogKindList = ["雑種","不明","アイリッシュ・ウルフハウンド","アイリッシュ・セター","秋田犬","アフガン・ハウンド","アーフェンピンシャー","アメリカン・エスキモー(アメリカンスピッツ）","アメリカン・コッカー・スパニエル","アメリカン・スタッフォードシャー・テリア","アメリカン・スピッツ（アメリカンエスキモー）","アメリカン・ピット・ブルテリア","アメリカン・フォックスハウンド","アラスカン・マラミュート","イタリアン・グレーハウンド","イングリッシュ・コッカー・スパニエル","イングリッシュ・スプリンガー・スパニエル","イングリッシュ・セター","イングリッシュ・ポインター","ウィペット","ウエスト・ハイランド・ホワイト・テリア","ウェルシュ・コーギー・カーディガン","ウェルシュ・コーギー・ペンブローク","ウェルシュ・スプリンガー・スパニエル","ウェルシュ・テリア","エアデール・テリア","オーストラリアン・キャトル・ドッグ","オーストラリアン・ケルピー","オーストラリアン・シェパード","オーストラリアン・シルキー・テリア","オーストラリアン・テリア","オールド・イングリッシュ・シープドッグ","甲斐犬","カニーンヘン・ダックスフンド","カーリーコーテッド・レトリーバー","紀州犬","キースホンド/ジャーマン・ウルフスピッツ","キャバリア・キング・チャールズ・スパニエル","キング・チャールズ・スパニエル","グレート・デーン","グレート・ピレニーズ","グレーハウンド","ケアーン・テリア","ケリー・ブルー・テリア","コーイケルホンディエ","コーカサス・シープドッグ","ゴードン・セター","コリー","コリア・ジンドー・ドッグ","ゴールデン・レトリーバー","サモエド","サルーキ","シー・ズー","シェットランド・シープドッグ","四国犬","柴犬（柴・豆柴を含む）","シベリアン・ハスキー","ジャイアント・シュナウザー","ジャック・ラッセル・テリア","シャー・ペイ","ジャーマン・シェパード・ドッグ","ジャーマン・ポインター","シーリハム・テリア","スカイ・テリア","スキッパーキ","スコティッシュ・テリア","スタッフォードシャー・ブル・テリア","スタンダード・シュナウザー","スタンダード・ダックスフンド","スタンダード・プードル","スピッツ(日本スピッツ）","スムース・コリー","セント・バーナード","ダルメシアン","ダンディ・ディンモント・テリア","チェサピーク・ベイ・レトリーバー","チベタン・スパニエル","チベタン・テリア","チベタン・マスティフ","チャイニーズ・クレステッド・ドッグ","チャウ・チャウ","チワワ","狆","トイ・プードル","トイ・マンチェスター・テリア","土佐犬","ドゴ・アルヘンティーノ","ドーベルマン","ナポリタン・マスティフ","日本テリア","日本スピッツ（スピッツ）","ノーフォーク・テリア","ノーリッチ・テリア","ニューファンドランド","パグ","バセット・ハウンド","バセンジー","バーニーズ・マウンテン・ドッグ","パピヨン","ハリア","ビアデッド・コリー","ビション・フリーゼ","ビーグル","プチ・バセット・グリフォン・バンデーン","プチ・ブラバンソン","ブービエ・デ・フランダース","プーミー","フラットコーテッド・レトリーバー","プーリー","ブリュッセル・グリフォン","ブリタニー・スパニエル","ブル・テリア","ブルドッグ","ブルマスティフ","フレンチ・ブルドッグ","ペキニーズ","ベドリントン・テリア","ベルジアン・グリフォン","ベルジアン・シェパード・ドッグ","ボストン・テリア","ボクサー","ボーダー・コリー","ボーダー・テリア","ポーチュギーズ・ウォーター・ドッグ","北海道犬","ポメラニアン","ポリッシュ・ローランド・シープドッグ","ボルゾイ","ボロニーズ","ホワイト・シェパード・ドッグ","マスティフ","マルチーズ","マンチェスター・テリア","ミニ・オーストラリアン・ブルドッグ","ミニチュア・シュナウザー","ミニチュア・ダックスフンド","ミニチュア・ピンシャー","ミニチュア・プードル","ミニチュア・ブル・テリア","ヨークシャー・テリア","ラサ・アプソ","ラフ・コリー（コリー）","ラブラドール・レトリーバー","レオンベルガー","レークランド・テリア","ワイアー・フォックス・テリア","ワイマラナー"]

    var catKindList = ["雑種","不明","アビシニアン","アメリカンカール","アメリカン・ショートヘア","アメリカンボブテイル","アメリカンワイヤーヘア","ヴァン猫","エジプシャンマウ","オシキャット","キムリック","クリルアイランドボブテイル","コーニッシュレックス","コラット","サイベリアン","ジャーマンレックス","ジャバニーズ","ジャパニーズボブテイル","シャム","シャルトリュー","シンガプーラ","スコティッシュフォールド","スフィンクス","セルカークレックス","ソマリ","ターキッシュアンゴラ","ターキッシュバン","デボンレックス","トンキニーズ","ドンスコイ","日本猫","ノルウェージャンフォレストキャット","バーマン","バーミーズ","ピーターボールド","ピクシーボブ","ヒマラヤン","ブリティッシュショートヘア","ペルシャ","ボンベイ","マンクス","マンチカン","ミンスキン","メインクーン","ヨーロピアンショートヘア","ラガマフィン","ラグドール","ラパーマ","リュコイ","ロシアンブルー"]
    
    var ageList = ["8ヶ月〜1歳","1〜2歳","3〜6歳","6〜9歳","10〜15歳","16歳〜","不明"]

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView = PopUpPickerView()
        pickerView.delegate = self
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(pickerView)
        } else {
            self.view.addSubview(pickerView)
        }


/*        kindPickerView = PopUpPickerView()
        kindPickerView.delegate = self
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(kindPickerView)
        } else {
            self.view.addSubview(kindPickerView)
        }

        areaPickerView = PopUpPickerView()
        areaPickerView.delegate = self
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(areaPickerView)
        } else {
            self.view.addSubview(areaPickerView)
        }
        
        agePickerView = PopUpPickerView()
        agePickerView.delegate = self
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(agePickerView)
        } else {
            self.view.addSubview(agePickerView)
        }
        */
        // 受け取った画像をImageViewに設定する
        petImageView.image = petImage
        
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {

        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        self.navigationController?.pushViewController(viewController4, animated: true)

    }

    @IBAction func handleKindSelectButton(_ sender: Any) {
        pickerView.tag = 1
        pickerView.showPicker()
    }
    @IBAction func handleAreaSelectButton(_ sender: Any) {
        pickerView.tag = 2
        pickerView.showPicker()
    }
    @IBAction func handleAgeSelectButton(_ sender: Any) {
        pickerView.tag = 3
        pickerView.showPicker()
    }

    //列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return dogKindList.count
        } else if pickerView.tag == 2 {
            return areaList.count
        } else {
            return ageList.count
        }
    }
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String? {
        if pickerView.tag == 1 {
            return dogKindList[row]
        } else if pickerView.tag == 2 {
            return areaList[row]
        } else {
            return ageList[row]
        }
    }
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView.tag == 1  {
            kindLabel.text = dogKindList[row]
            kindLabel.textColor = UIColor.black
        } else if pickerView.tag == 2 {
            areaLabel.text = areaList[row]
            areaLabel.textColor = UIColor.black
        } else {
            ageLabel.text = ageList[row]
            ageLabel.textColor = UIColor.black
        }
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
