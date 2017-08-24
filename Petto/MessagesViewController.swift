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
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    
    let userDefaults = UserDefaults.standard
//    var messageData: MessageData?
    
    var roomId: String?
    var uid: String?
    var userImageString: String?
    var pid: String?
    var petImageString: String?
    
    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    //    var userToPetFlag = false
    
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
        
        self.senderId = "testID"
        self.senderDisplayName = "testName"
        
        // 初期設定
        self.initialSettings()
        
        self.finishReceivingMessage()
        
        print("DEBUG_PRINT: MessagesViewController.viewDidLoad end")
        
    }
    
    private func initialSettings() {
        print("DEBUG_PRINT: MessagesViewController.initialSettings start")
        
        if let uid = uid, let pid = pid {
            roomId = uid + pid
            
            var userImage = UIImage(named: "user")
            if userImageString != nil {
                userImage = UIImage(data: NSData(base64Encoded: userImageString!, options: .ignoreUnknownCharacters)! as Data)
            }
            var petImage = UIImage(named: "catProfile")
            if petImageString != nil {
                petImage = UIImage(data: NSData(base64Encoded: petImageString!, options: .ignoreUnknownCharacters)! as Data)
            }
            
            self.senderId = uid
            self.senderDisplayName = userDefaults.string(forKey: DefaultString.DisplayName)!
            // 自分のアバター画像設定
            self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: userImage, diameter: 64)
            // 相手のアバター画像設定
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: petImage, diameter: 64)
            
            // 吹き出しの色設定
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
            self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
            
            // 過去のmessageデータを取得
            self.getMessages()
        }
        
        print("DEBUG_PRINT: MessagesViewController.initialSettings end")
    }
    
    
    func getMessages() {
        print("DEBUG_PRINT: MessagesViewController.getMessages start")
        
        let ref = FIRDatabase.database().reference().child(Paths.MessagePath).child(roomId!)
        // Messageの取得
        ref.queryLimited(toLast: 100).observe(.value, with: { (snapshot) in
            
            print("DEBUG_PRINT: MessagesViewController.getMessages .observeイベントが発生しました。")
            
            if self.observing == false {
                
                for v in snapshot.children {
                    if v is FIRDataSnapshot {
                        
                        let messageData = MessageData(snapshot: snapshot, myId: self.roomId!)
                        let senderId = messageData.senderId
                        let senderDisplayName = messageData.senderDisplayName
                        let date = messageData.timestamp! as Date
                        if let image = messageData.image {
                            let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: JSQPhotoMediaItem(image: image))
                            self.messages.append(message!)
                        }else if let text = messageData.text {
                            let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
                            self.messages.append(message!)
                        }
                        self.collectionView.reloadData()
                    }
                }
            }
            self.observing = true
            
        }) { (error) in
            print(error.localizedDescription)
        }
        print("DEBUG_PRINT: MessagesViewController.getMessages end")
        
    }
    
    
    // 送信ボタンを押した時の挙動
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("DEBUG_PRINT: MessagesViewController.didPressSend start")
        
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message!)
        
        let time = NSDate.timeIntervalSinceReferenceDate

        var inputData = [String : Any]()  //message
        
        // Firebase連携用
        inputData["senderId"] = senderId
        inputData["senderDisplayName"] = senderDisplayName
        inputData["text"] = text
        inputData["timestamp"] = String(time)
        
        // insert
        let ref = FIRDatabase.database().reference()
        let key = ref.child(Paths.MessagePath).child(roomId!).childByAutoId().key
        ref.child(Paths.MessagePath).child(roomId!).child(key).setValue(inputData)
        
        // update
        ref.child(Paths.UserPath).child(uid!).child("messages").updateChildValues([roomId! : true])
        ref.child(Paths.PetPath).child(pid!).child("messages").updateChildValues([roomId! : true])
        
        // 更新
        finishSendingMessage(animated: true)
        sendAutoMessage()
        
        print("DEBUG_PRINT: MessagesViewController.didPressSend end")
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
    
    func tappedAvatar() {
        print("tapped user avatar")
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        viewController4.delegate = self
        self.navigationController?.pushViewController(viewController4, animated: true)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerEditedImage] {
            sendImageMessage(image: image as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)
        
    }

    func sendImageMessage(image: UIImage) {
        print("DEBUG_PRINT: MessagesViewController.sendImageMessage start")
        
        let imageMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQPhotoMediaItem(image: image))
        messages.append(imageMessage!)
        
        let imageData = UIImageJPEGRepresentation(image , 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        let time = NSDate.timeIntervalSinceReferenceDate
        
        // Firebase連携用
        var inputData = [String : Any]()  //message
        
        inputData["senderId"] = senderId
        inputData["senderDisplayName"] = senderDisplayName
        inputData["imageString"] = imageString
        inputData["timestamp"] = String(time)
        
        // insert
        let ref = FIRDatabase.database().reference()
        let key = ref.child(Paths.MessagePath).child(roomId!).childByAutoId().key
        ref.child(Paths.MessagePath).child(roomId!).child(key).setValue(inputData)
        // update
        ref.child(Paths.UserPath).child(uid!).child("messages").updateChildValues([roomId! : true])
        ref.child(Paths.PetPath).child(pid!).child("messages").updateChildValues([roomId! : true])

        finishSendingMessage(animated: true)
        sendAutoMessage()
        
        print("DEBUG_PRINT: MessagesViewController.sendImageMessage end")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if messages[indexPath.item].isMediaMessage {
            let media = messages[indexPath.item].media
            if (media?.isKind(of: JSQPhotoMediaItem.self))!{
                print("tapped Image")
            }
        }
    }
}

extension MessagesViewController: ImageSelectViewDelegate{
    
    func didCompletion(image :UIImage){
        sendImageMessage(image: image)
    }
    
}
