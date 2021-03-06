//
//  MessagesViewController.swift
//  Petto
//
//  Created by admin on 2017/07/05.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase
import FirebaseUI
import JSQMessagesViewController
import SVProgressHUD
import Toucan

class MessagesViewController: JSQMessagesViewController, UIGestureRecognizerDelegate {
    
    var roomData: RoomData?
    var messageData: MessageData?
    
    private var messages: [JSQMessage] = []
    private var incomingBubble: JSQMessagesBubbleImage!
    private var outgoingBubble: JSQMessagesBubbleImage!
    private var incomingAvatar: JSQMessagesAvatarImage!
    private var outgoingAvatar: JSQMessagesAvatarImage!
    
    // テスト用
    private let targetUser: JSON = ["senderId": "targetId", "senderDisplayName": "targetDisplayName"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG_PRINT: MessagesViewController.viewDidLoad start")
        
        if roomData?.blocked != nil {
            SVProgressHUD.showError(withStatus: "ブロック中です")
        }
        
        // 画面タップでキーボードを隠す
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGestureRecognizer.delegate = self
        self.collectionView?.addGestureRecognizer(tapGestureRecognizer)

        // 初期設定
        self.collectionView.register(UINib(nibName: "CellWithConfimationButtons", bundle: nil), forCellWithReuseIdentifier: "incomingCell")
        self.collectionView.register(UINib(nibName: "CellWithConfimationButtons", bundle: nil), forCellWithReuseIdentifier: "outgoingCell")

        // 吹き出しの色設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        self.senderId = UserDefaults.standard.string(forKey: DefaultString.Uid)
        self.senderDisplayName = UserDefaults.standard.string(forKey: DefaultString.DisplayName)!
        
        if checkSender(){
            // 自分のアバター画像設定
            let view = UIImageView()
            if let key = self.roomData?.userId {
                view.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
            }
            self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: view.image, diameter: 64)
            // 相手のアバター画像設定
            let view2 = UIImageView()
            if let key = self.roomData?.petId {
                view2.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
            }
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: view2.image, diameter: 64)
        }else{
            // 自分のアバター画像設定
            let view = UIImageView()
            if let key = self.roomData?.petId {
                view.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
            }
            self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: view.image, diameter: 64)
            // 相手のアバター画像設定
            let view2 = UIImageView()
            if let key = self.roomData?.userId {
                view2.sd_setImage(with: StorageRef.getRiversRef(key: key), placeholderImage: StorageRef.placeholderImage)
            }
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: view2.image, diameter: 64)
        }
        // 一番下までスクロールして表示
        automaticallyScrollsToMostRecentMessage = true
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        self.collectionView?.collectionViewLayout.springinessEnabled = true

        // roomDataからメッセージを取得
        getMessages()
        
        print("DEBUG_PRINT: MessagesViewController.viewDidLoad end")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DEBUG_PRINT: MessagesViewController.viewWillDisappear start")
        
        let ref = Database.database().reference()
        
        if self.messages.count == 0 {
            // Roomの削除
//            ref.child(Paths.RoomPath).child((self.roomData?.id)!).removeValue()
            ref.child(Paths.MessagePath).child((self.roomData?.id)!).removeValue()
            ref.child(Paths.UserPath).child((self.roomData?.userId)!).child("roomIds").child((self.roomData?.id)!).removeValue()
            ref.child(Paths.PetPath).child((self.roomData?.petId)!).child("roomIds").child((self.roomData?.id)!).removeValue()
            ref.child(Paths.UserPath).child((self.roomData?.breederId)!).child("unReadRoomIds").child((self.roomData?.id)!).removeValue()
            print("DEBUG_PRINT: MessagesViewController.viewWillDisappear .removeValueイベントが発生しました。")
        } else {
            // 既読にする
            if checkSender() {
                ref.child(Paths.UserPath).child((self.roomData?.userId)!).child("unReadRoomIds").child((self.roomData?.id)!).removeValue()
            }else{
                ref.child(Paths.UserPath).child((self.roomData?.breederId)!).child("unReadRoomIds").child((self.roomData?.id)!).removeValue()
            }
        }
        
        let ref1 = Database.database().reference().child(Paths.MessagePath).child((self.roomData?.id)!)
        ref1.removeAllObservers()
        
        print("DEBUG_PRINT: MessagesViewController.viewWillDisappear end")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("DEBUG_PRINT: MessagesViewController.viewDidDisappear start")
        print("DEBUG_PRINT: MessagesViewController.viewDidDisappear end")
    }
    

    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func dismissKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return nil
        } else {
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        //return 17.0
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return 0.0
        } else {
            return 17.0
        }
    }
    
    func getMessages() {
        print("DEBUG_PRINT: MessagesViewController.getMessages start")
        
        let ref = Database.database().reference().child(Paths.MessagePath).child((self.roomData?.id)!)
        // Messageの取得
        SVProgressHUD.show(RandomImage.getRandomImage(), status: "Now Loading...")
        ref.queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MessagesViewController.getMessages .observeSingleEventイベントが発生しました。")
            
            for v in snapshot.children {
                if let _v = v as? DataSnapshot {
                    let messageData = MessageData(snapshot: _v, myId: (self.roomData?.id)!)
                    let senderId = messageData.senderId
                    let senderDisplayName = messageData.senderDisplayName
                    let date = messageData.timestamp! as Date
                    if messageData.text == nil {
                        let view = UIImageView()
                        view.sd_setImage(with: StorageRef.getRiversRef(key: messageData.id!), placeholderImage: StorageRef.placeholderImage)
                        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: JSQPhotoMediaItem(image: view.image))
                        self.messages.append(message!)
                        self.finishReceivingMessage()
                    }else{
                        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: messageData.text)
                        self.messages.append(message!)
                        self.finishReceivingMessage()
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.showError(withStatus: "データ通信でエラーが発生しました")
        }
        print("DEBUG_PRINT: MessagesViewController.getMessages end")
        
    }
    
    
    // 送信ボタンを押した時の挙動
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("DEBUG_PRINT: MessagesViewController.didPressSend start")
        
        if roomData?.blocked != nil {
            SVProgressHUD.showError(withStatus: "ブロック中です")
        }else{
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            messages.append(message!)
            // データセット
            let time = NSDate.timeIntervalSinceReferenceDate
            var inputData = [String : Any]()  //message
            inputData["senderId"] = senderId
            inputData["senderDisplayName"] = senderDisplayName
            inputData["text"] = text
            inputData["timestamp"] = String(time)
            
            // Firebase連携
            updateMessageData(inputData: inputData, lastMessage: text, image: nil)
            
            // 更新
            finishSendingMessage(animated: true)
            //sendAutoMessage()
        }
        
        print("DEBUG_PRINT: MessagesViewController.didPressSend end")
    }
    
    func sendImageMessage(image: UIImage) {
        print("DEBUG_PRINT: MessagesViewController.sendImageMessage start")
        
        let imageMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQPhotoMediaItem(image: image))
        messages.append(imageMessage!)
        // データセット
        let time = NSDate.timeIntervalSinceReferenceDate
        var inputData = [String : Any]()  //message
        inputData["senderId"] = senderId
        inputData["senderDisplayName"] = senderDisplayName
        inputData["timestamp"] = String(time)
        
        let lastMessage = "[写真が届いています]"
        let photeImage = Toucan(image: image).resize(CGSize(width: 200, height: 200), fitMode: Toucan.Resize.FitMode.clip).image

        // Firebase連携
        updateMessageData(inputData: inputData ,lastMessage: lastMessage, image: photeImage)
        
        // 更新
        finishSendingMessage(animated: true)
        //sendAutoMessage()
        
        print("DEBUG_PRINT: MessagesViewController.sendImageMessage end")
    }
    
    func storageUpload(photeImage: UIImage, key: String){
        
        if let data = UIImageJPEGRepresentation(photeImage, 0.25) {
            StorageRef.getRiversRef(key: key).putData(data , metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Image Uploaded Error")
                    print(error!)
                } else {
                    print("Image Uploaded Succesfully")
                }
            }
        }
    }
    
    func updateMessageData(inputData: [String : Any], lastMessage: String ,image: UIImage?){
        print("DEBUG_PRINT: MessagesViewController.updateMessageData start")
        
        // messageをinsert
        let ref = Database.database().reference()
        let key = ref.child(Paths.MessagePath).child((self.roomData?.id)!).childByAutoId().key
        ref.child(Paths.MessagePath).child((self.roomData?.id)!).child(key).setValue(inputData)
        if image != nil {
            storageUpload(photeImage: image!, key: key)
        }
        
        // room,user,petをupdate
        if checkSender() {
            // 自分があずかり人の場合
            let childUpdates = ["/\(Paths.RoomPath)/\(self.roomData!.id!)/lastMessage/": lastMessage,
                                "/\(Paths.RoomPath)/\(self.roomData!.id!)/updateAt/": inputData["timestamp"]!,
                                "/\(Paths.UserPath)/\(self.roomData!.userId!)/roomIds/\(self.roomData!.id!)": true,
                                "/\(Paths.PetPath)/\(self.roomData!.petId!)/roomIds/\(self.roomData!.id!)": true,
                                "/\(Paths.UserPath)/\(self.roomData!.breederId!)/unReadRoomIds/\(self.roomData!.id!)/": true] as [String : Any] // 相手の未読をON
            ref.updateChildValues(childUpdates)
        }else{
            // 自分がブリーダーの場合
            let childUpdates = ["/\(Paths.RoomPath)/\(self.roomData!.id!)/lastMessage/": lastMessage,
                                "/\(Paths.RoomPath)/\(self.roomData!.id!)/updateAt/": inputData["timestamp"]!,
                                "/\(Paths.UserPath)/\(self.roomData!.userId!)/roomIds/\(self.roomData!.id!)": true,
                                "/\(Paths.PetPath)/\(self.roomData!.petId!)/roomIds/\(self.roomData!.id!)": true,
                                "/\(Paths.UserPath)/\(self.roomData!.userId!)/unReadRoomIds/\(self.roomData!.id!)/": true] as [String : Any] // 相手の未読をON
            ref.updateChildValues(childUpdates)
        }
        
        print("DEBUG_PRINT: MessagesViewController.updateMessageData end")
    }
    
    
    // 表示するメッセージの内容
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    // 表示するメッセージの背景を指定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.item].senderId == senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // 表示するユーザーアイコンを指定。nilを指定すると画像がでない
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        if messages[indexPath.item].senderId != self.senderId {
            return incomingAvatar
        }
        return self.outgoingAvatar
    }
    
    // メッセージの件数を指定
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // テストでメッセージを送信するためのメソッド
    private func sendAutoMessage() {
        print("DEBUG_PRINT: MessagesViewController.sendAutoMessage start")
        
        let message = JSQMessage(senderId: targetUser["senderId"].string, displayName: targetUser["senderDisplayName"].string, text: "返信するぞ")
        messages.append(message!)
        finishReceivingMessage(animated: true)
        
        print("DEBUG_PRINT: MessagesViewController.sendAutoMessage end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 送信時刻を出すために高さを調整する
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if message.date.timeIntervalSince(previousMessage.date) / 60 > 1 {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
            }
        }
        return nil
    }
    
    // 送信時刻を出すために高さを調整する
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            let message = messages[indexPath.item]
            if message.date.timeIntervalSince(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        // ユーザーアイコンに対してジェスチャーをつける
        let avatarImageTap = UITapGestureRecognizer(target: self, action: #selector(MessagesViewController.tappedAvatar))
        cell.avatarImageView?.isUserInteractionEnabled = true
        cell.avatarImageView?.addGestureRecognizer(avatarImageTap)
        
        // 文字色を変える
        if messages[indexPath.item].senderId != senderId {
            cell.textView?.textColor = UIColor.darkGray
        } else {
            cell.textView?.textColor = UIColor.white
        }
        
        return cell
    }
    
    @objc func tappedAvatar() {
        print("tapped user avatar")
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        if roomData?.blocked != nil {
            SVProgressHUD.showError(withStatus: "ブロック中です")
        }else{
            let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
            viewController4.delegate = self
            self.navigationController?.pushViewController(viewController4, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerEditedImage] {
            sendImageMessage(image: image as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if messages[indexPath.item].isMediaMessage {
            let media = messages[indexPath.item].media
            if (media?.isKind(of: JSQPhotoMediaItem.self))!{
                print("tapped Image")
            }
        }
    }
    
    func checkSender () -> Bool {
        var result = false
        // 自分のuidを取得
        let uid = UserDefaults.standard.string(forKey: DefaultString.Uid)!
        if self.roomData?.breederId != uid {
            print("わたしはあずかり人です")
            result = true
        }
        return result
    }
}

extension MessagesViewController: ImageSelectViewDelegate{
    
    func didCompletion(image :UIImage){
        sendImageMessage(image: image)
    }
    
}
