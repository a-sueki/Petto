//
//  HistoryViewController.swift
//  Petto
//
//  Created by admin on 2017/09/16.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import SCLAlertView

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { //, HistoryDelegate
    
    var petData: PetData?
    var leaveDataArray: [LeaveData] = []

    var image: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: HistoryTableViewController.viewDidLoad start")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "historyCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        print("DEBUG_PRINT: HistoryTableViewController.viewDidLoad end")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: HistoryTableViewController.viewWillAppear start")
        
        self.leaveDataArray.removeAll()
        if self.petData != nil, self.petData?.historys != nil, !(self.petData?.historys.isEmpty)! {
            self.read()
        }
        
        print("DEBUG_PRINT: HistoryTableViewController.viewWillAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: HistoryTableViewController.viewWillDisappear start")
        
        if self.petData != nil, self.petData?.historys != nil, !(self.petData?.historys.isEmpty)! {
            for (leaveId,_) in (self.petData?.historys)! {
                let ref = Database.database().reference().child(Paths.LeavePath).child(leaveId)
                ref.removeAllObservers()
            }
        }
        
        print("DEBUG_PRINT: HistoryTableViewController.viewWillDisappear end")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // TextField以外の部分をタッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("DEBUG_PRINT: HistoryTableViewController.touchesBegan start")
        
        self.view.endEditing(true)
        
        print("DEBUG_PRINT: HistoryTableViewController.touchesBegan end")
    }
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG_PRINT: HistoryViewController.numberOfRowsInSection start")
        print("DEBUG_PRINT: HistoryViewController.numberOfRowsInSection end")
        return self.leaveDataArray.count
    }
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG_PRINT: HistoryViewController.didSelectRowAt start")
        
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print("DEBUG_PRINT: HistoryViewController.didSelectRowAt end")
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        print("DEBUG_PRINT: HistoryViewController.editingStyleForRowAt start")
        print("DEBUG_PRINT: HistoryViewController.editingStyleForRowAt end")
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        print("DEBUG_PRINT: HistoryViewController.estimatedHeightForRowAt start")
        print("DEBUG_PRINT: HistoryViewController.estimatedHeightForRowAt end")
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    //返すセルを決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DEBUG_PRINT: HistoryViewController.cellForRowAt start")
        
        //xibとカスタムクラスで作成したCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        cell.shearButton.addTarget(self, action:#selector(handleFacebookButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.facebookButton.addTarget(self, action:#selector(handleFacebookButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.reportButton.addTarget(self, action:#selector(handleReportButton(sender:event:)), for:  UIControlEvents.touchUpInside)

/*        //自作セルのデリゲート先に自分を設定する。
        cell.delegate = self
        // セル内のボタンのアクションをソースコードで設定する
        cell.cameraImageButton.addTarget(self, action:#selector(handleCameraButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.cameraLabelButton.addTarget(self, action:#selector(handleCameraButton(sender:event:)), for:  UIControlEvents.touchUpInside)

        cell.userCommentSaveButton.addTarget(self, action:#selector(handleUserCommentSaveButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        cell.breederCommentSaveButton.addTarget(self, action:#selector(handleBreederCommentSaveButton(sender:event:)), for:  UIControlEvents.touchUpInside)
*/
        
        cell.setData(leaveData: self.leaveDataArray[indexPath.row])
        
        if self.leaveDataArray[indexPath.row].userComment != nil || self.leaveDataArray[indexPath.row].breederComment != nil{
            cell.noImageView.isHidden = true
        }else{
            cell.noImageView.isHidden = false
        }
        // history画面は参照のみ
        cell.userCommentTextFeild.isEnabled = false
        cell.breederCommentTextField.isEnabled = false
        cell.userCommentSaveButton.isHidden = true
        cell.breederCommentSaveButton.isHidden = true
        cell.cameraLabelButton.isHidden = true
        cell.cameraImageButton.isHidden = true

/*
        //TODO: 自分の場合のみ、自分のコメント編集可
        if self.leaveDataArray[indexPath.row].breederId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            // ブリーダーの場合
            cell.userCommentTextFeild.isEnabled = false
            cell.userCommentTextFeild.textColor = UIColor.gray
            cell.userCommentSaveButton.isHidden = true
            cell.cameraLabelButton.isHidden = true
            cell.cameraImageButton.isHidden = true
            if self.leaveDataArray[indexPath.row].breederComment == nil || self.leaveDataArray[indexPath.row].breederComment != "[コメントはありません]" {
                cell.breederCommentTextField.text = ""
                cell.breederCommentTextField.placeholder = "コメントを入力してください"
            }
        }else if self.leaveDataArray[indexPath.row].userId == UserDefaults.standard.string(forKey: DefaultString.Uid) {
            // あずかり人の場合
            cell.breederCommentTextField.isEnabled = false
            cell.breederCommentTextField.textColor = UIColor.gray
            cell.breederCommentSaveButton.isHidden = true
            if self.leaveDataArray[indexPath.row].userComment == nil || self.leaveDataArray[indexPath.row].userComment != "[コメントはありません]" {
                cell.userCommentTextFeild.text = ""
                cell.userCommentTextFeild.placeholder = "コメントを入力してください"
            }

        }else{
            // 一般ユーザ（参照のみ）の場合
            cell.userCommentTextFeild.isEnabled = false
            cell.breederCommentTextField.isEnabled = false
            cell.userCommentSaveButton.isHidden = true
            cell.breederCommentSaveButton.isHidden = true
            cell.cameraLabelButton.isHidden = true
            cell.cameraImageButton.isHidden = true
        }
 */
        
        print("DEBUG_PRINT: HistoryViewController.cellForRowAt end")
        return cell
    }

    @objc func handleReportButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: HistoryViewController.handleReportButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        
        let alertView = SCLAlertView(appearance: SCLAlert.appearance)
        let textField = alertView.addTextField("違反内容など")
        let nameFeild = alertView.addTextField("あなたのお名前")
        let mailFeild = alertView.addTextField("あなたのメールアドレス")
        alertView.addButton("通報する"){
            if let violationContent = textField.text, let name = nameFeild.text ,let mail = mailFeild.text{
                self.excuteReport(text: violationContent, mail:mail, name:name, index: (indexPath?.row)!)
            }
        }
        alertView.addButton("キャンセル", target:self, selector:#selector(HistoryViewController.cancel))
        alertView.showEdit("違反報告", subTitle: "\n違反内容について記載し、通報して下さい。\n")
        
        print("DEBUG_PRINT: HistoryViewController.handleReportButton end")
    }
    func excuteReport(text :String, mail :String, name :String, index:Int) {
        print("DEBUG_PRINT: HistoryViewController.excuteReport start")
        
        var inputData = [String : Any]()
        let time = NSDate.timeIntervalSinceReferenceDate
        let ref = Database.database().reference()
        
        let key = ref.child(Paths.ViolationHistoryPath).childByAutoId().key
        inputData["mail"] = mail
        inputData["name"] = name
        inputData["text"] = text
        inputData["targetID"] = self.leaveDataArray[index].id!
        inputData["createAt"] = String(time)
        inputData["createBy"] = UserDefaults.standard.string(forKey: DefaultString.Uid) ?? "guest"
        // insert
        ref.child(Paths.ViolationHistoryPath).child(key).setValue(inputData)
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        print("DEBUG_PRINT: HistoryViewController.excuteReport end")
    }
    
    @objc func cancel() {
        print("DEBUG_PRINT: HistoryViewController.cancel start")
        print("DEBUG_PRINT: HistoryViewController.cancel end")
    }

    @objc func handleFacebookButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: HistoryViewController.handleFacebookButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 共有する項目
        let shareText = ShareString.text
        let shareWebsite = ShareString.website
        // 画像を追加
        let view = UIImageView()
        var shareImage = UIImage()
        view.sd_setImage(with: StorageRef.getRiversRef(key: self.leaveDataArray[indexPath!.row].id!), placeholderImage: StorageRef.placeholderImage)
        if view.image != StorageRef.placeholderImage {
            shareImage = view.image!
        }
        let shareItems = [shareText, shareWebsite, shareImage] as [Any]
        
        // LINEで送るボタンを追加
        let line = LINEActivity()
        let avc = UIActivityViewController(activityItems: shareItems, applicationActivities: [line])
        
        present(avc, animated: true, completion: nil)
        
        print("DEBUG_PRINT: HistoryViewController.handleFacebookButton end")
    }
 
    
    func read() {
        print("DEBUG_PRINT: HistoryViewController.read start")
        
        // historysのleaveを取得
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        for (leaveId,_) in (self.petData?.historys)! {
            let ref = Database.database().reference().child(Paths.LeavePath).child(leaveId).queryOrderedByKey()
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: HistoryViewController.read .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    // leaveを取得
                    let leaveData = LeaveData(snapshot: snapshot, myId: leaveId)
                    self.leaveDataArray.append(leaveData)
                    
                    // 実際の開始日で並び替え
                    self.leaveDataArray = self.leaveDataArray.sorted(by: {
                        DateCommon.stringToDate($0.actualStartDate!, dateFormat: DateCommon.dateFormat).compare(DateCommon.stringToDate($1.actualStartDate!, dateFormat: DateCommon.dateFormat)) == ComparisonResult.orderedDescending
                    })
                }
                
                // tableViewを再表示する
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: HistoryViewController.read [DispatchQueue.main.async]")
                    //テーブルビューをリロード
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
            }
        }
        print("DEBUG_PRINT: HistoryViewController.read end")
    }
    
/*    // カメラがタップされたらカメラを起動して写真を取得
    func handleCameraButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: HistoryViewController.handleLeaveInfoButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let imageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        imageSelectViewController.delegate = self
        self.navigationController?.pushViewController(imageSelectViewController, animated: true)
        
        if self.image != nil {
            let time = NSDate.timeIntervalSinceReferenceDate
            let ref = FIRDatabase.database().reference()
            let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveDataArray[(indexPath?.row)!].id!)/updateAt/": String(time)] as [String : Any]
            ref.updateChildValues(childUpdates)
            self.tableView.reloadData()
        }
        
        print("DEBUG_PRINT: HistoryViewController.handleLeaveInfoButton end")
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] {
            setImage(image: image as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func setImage(image: UIImage){
        self.image = image
    }


    //デリゲートメソッド
    func userCommentTextFeildDidEndEditing(cell: HistoryTableViewCell, value:String) {
        print("DEBUG_PRINT: HistoryViewController.userCommentTextFeildDidEndEditing start")
        //変更されたセルのインデックスを取得する。
        let index = self.tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to:self.tableView))
        
        //データを変更する。
        self.leaveDataArray[index!.row].userComment = value
        print("DEBUG_PRINT: HistoryViewController.userCommentTextFeildDidEndEditing end")
    }
    //デリゲートメソッド
    func breederCommentTextFieldDidEndEditing(cell: HistoryTableViewCell, value:String) {
        //変更されたセルのインデックスを取得する。
        let index = self.tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to:self.tableView))
        
        //データを変更する。
        self.leaveDataArray[index!.row].breederComment = value
        print(self.leaveDataArray)
    }

    
    func handleUserCommentSaveButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: HistoryViewController.handleUserCommentSaveButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        if let userComment = self.leaveDataArray[(indexPath?.row)!].userComment {
            let time = NSDate.timeIntervalSinceReferenceDate
            let ref = FIRDatabase.database().reference()
            let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveDataArray[(indexPath?.row)!].id!)/userComment/": userComment,
                                "/\(Paths.LeavePath)/\(self.leaveDataArray[(indexPath?.row)!].id!)/updateAt/": String(time)] as [String : Any]
            ref.updateChildValues(childUpdates)
            
            self.leaveDataArray[(indexPath?.row)!].userComment = userComment
            self.tableView.reloadData()
        }
        
        print("DEBUG_PRINT: HistoryViewController.handleUserCommentSaveButton end")
    }
    func handleBreederCommentSaveButton(sender: UIButton, event:UIEvent) {
        print("DEBUG_PRINT: HistoryViewController.handleBreederCommentSaveButton start")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //xibとカスタムクラスで作成したCellのインスタンスを作成
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath!) as! HistoryTableViewCell
        let breederComment = cell.breederCommentTextField.text
        
        if breederComment != nil {
            let time = NSDate.timeIntervalSinceReferenceDate
            let ref = FIRDatabase.database().reference()
            let childUpdates = ["/\(Paths.LeavePath)/\(self.leaveDataArray[(indexPath?.row)!].id!)/breederComment/": breederComment!,
                                "/\(Paths.LeavePath)/\(self.leaveDataArray[(indexPath?.row)!].id!)/updateAt/": String(time)] as [String : Any]
            ref.updateChildValues(childUpdates)
            
            self.leaveDataArray[(indexPath?.row)!].breederComment = breederComment
            self.tableView.reloadData()
        }
        
        print("DEBUG_PRINT: HistoryViewController.handleBreederCommentSaveButton end")
    }
*/
}
/*
extension HistoryViewController: ImageSelectViewDelegate{
    
    func didCompletion(image :UIImage){
        setImage(image: image)
    }
    
}
 */
