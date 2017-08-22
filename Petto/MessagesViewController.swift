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

    var petData: PetData?
    var roomData: RoomData?
    var memberData: MemberData?
    var messageData: MessageData?

//        var userData: UserData?
//        var messageList: [MessageData]?

    // FIRDatabaseのobserveEventの登録状態を表す
    var observing = false
    var inputData = [String : Any]()  //message
    var userToPetFlag = false
    
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

        let ref = FIRDatabase.database().reference()
        //roomIdをセット
        print(userDefaults.string(forKey: DefaultString.Uid)! + (self.petData?.id)!)
        let uid = userDefaults.string(forKey: DefaultString.Uid)!
        let roomId = uid + (self.petData?.id)!
        
        // 初期設定
        self.initialSettings()
        
        // 過去のmessageデータを取得
        self.getMessages()
        
        self.finishReceivingMessage()

        
        /*
        // Roomの取得
        ref.child(Paths.RoomPath).child(roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MessagesViewController.viewDidLoad room.observeSingleEventイベントが発生しました。")

            self.roomData = RoomData(snapshot: snapshot, myId: roomId)
            print(self.roomData)
        
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Memberの取得
        ref.child(Paths.MemberPath).child(roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MessagesViewController.viewDidLoad member.observeSingleEventイベントが発生しました。")
            
            self.memberData = MemberData(snapshot: snapshot, myId: roomId)
            print(self.memberData)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // 自分がuserの場合、userToPetFlagをtrueにする
        if uid == self.memberData?.userId {
            userToPetFlag = true
        }
        // Messageの取得
        ref.child(Paths.MessagePath).child(roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("DEBUG_PRINT: MessagesViewController.viewDidLoad message.observeSingleEventイベントが発生しました。")
                self.messageData = MessageData(snapshot: snapshot, myId: roomId)
                print(self.messageData)
            
        }) { (error) in
            print(error.localizedDescription)
        }
         */
        

        
        
        // Firebaseから登録済みUserデータを取得
/*        if FIRAuth.auth()?.currentUser != nil {
            // 要素が追加されたら再表示
            let useRef = FIRDatabase.database().reference().child(Paths.UserPath)
            useRef.observe(.childAdded, with: { (snapshot) in
                print("DEBUG_PRINT: MessagesViewController.viewDidLoad user.childAddedイベントが発生しました。")
                
                // self.userDataクラスを生成して受け取ったデータを設定する
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    self.userData = UserData(snapshot: snapshot, myId: uid)
                }
                //Firebaseからアカウント情報取得
                let user = FIRAuth.auth()?.currentUser
                self.userData?.displayName = user?.displayName

                // 過去のmessageデータを取得
                //self.getMessages()
                // 初期設定
                self.initialSettings()
                
                self.finishReceivingMessage()

            })
            
            // FIRDatabaseのobserveEventが上記コードにより登録されたため
            // trueとする
            observing = true
        }
*/
        print("DEBUG_PRINT: MessagesViewController.viewDidLoad end")

    }
    
    private func initialSettings() {
        print("DEBUG_PRINT: MessagesViewController.initialSettings start")

        var userImage = UIImage(named: "user")
        if let userImageString = userDefaults.string(forKey: DefaultString.Phote) {
            userImage = UIImage(data: NSData(base64Encoded: userImageString, options: .ignoreUnknownCharacters)! as Data)
        }
        
        self.senderId = userDefaults.string(forKey: DefaultString.Uid)!
        self.senderDisplayName = userDefaults.string(forKey: DefaultString.DisplayName)!
        // 自分のアバター画像設定
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: userImage, diameter: 64)
        // 相手のアバター画像設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: self.petData?.image, diameter: 64)

        
/*
        // 自分=userの場合
        if  self.userData?.id == FIRAuth.auth()?.currentUser?.uid {
            print("DEBUG_PRINT: MessagesViewController.initialSettings 私はUSER\(self.userData?.id)です。")
            self.senderId = self.userData?.id
            self.senderDisplayName = self.userData?.displayName
            // 相手のアバター画像設定
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: self.petData?.image, diameter: 64)
            // 自分のアバター画像設定
            self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: self.userData?.image, diameter: 64)
        }else{
            // 自分=petの場合
            print("DEBUG_PRINT: MessagesViewController.initialSettings 私はPET\(self.petData?.id)です。")
            self.senderId = self.petData?.id
            self.senderDisplayName = self.petData?.name ?? "名無しペット" + "の飼い主さん"
            // 相手のアバター画像設定
            self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: self.userData?.image, diameter: 64)
            // 自分のアバター画像設定
            self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: self.petData?.image, diameter: 64)
        }
 */

        // 吹き出しの色設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        print("DEBUG_PRINT: MessagesViewController.initialSettings end")
    }
    
    func getMessages() {
        print("DEBUG_PRINT: MessagesViewController.getMessages start")
        //TODO:Firebaseから登録済みmessageデータを取得
        if let uid = userDefaults.string(forKey: DefaultString.Uid), let pid = self.petData?.id {
            print("DEBUG_PRINT: MessagesViewController.getMessages 1")
            // keyを取得
            let roomId = uid + pid
            print(roomId)
            let messageRef = FIRDatabase.database().reference().child(Paths.MessagePath).child(roomId)
            messageRef.queryLimited(toLast: 100).observe(.childAdded, with: { (snapshot) in
                
                print("DEBUG_PRINT: MessagesViewController.getMessages message.childAddedイベントが発生しました。")
                print(snapshot)

                let messageData = MessageData(snapshot: snapshot, myId: roomId)
                let senderId = messageData.senderId ?? "a"
                let senderDisplayName = messageData.senderDisplayName ?? "c"
//                let data = messageData.timestamp

                print("DEBUG_PRINT: MessagesViewController.getMessages 2")
                print(senderId)
                if let imageString = messageData.imageString {
                    print("しゃしんをせっとー")
                    //JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: <#T##Date!#>, media: <#T##JSQMessageMediaData!#>)
                    //                    self.messages.append(JSQMessage(senderId: senderId,  displayName: displayName, media: ))
                }else if let text = messageData.text {
                    self.messages.append(JSQMessage(senderId: senderId,  displayName: senderDisplayName, text: text))
                }
                self.collectionView.reloadData()
                
                print("DEBUG_PRINT: MessagesViewController.getMessages 3")
                
                
            })
        }
        print("DEBUG_PRINT: MessagesViewController.getMessages end")

    }
    
    
    // 送信ボタンを押した時の挙動
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("DEBUG_PRINT: MessagesViewController.didPressSend start")

        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message!)
        
        // 更新
        finishSendingMessage(animated: true)
        
        // NSDate型 "date" をUNIX時間 "dateUnix" に変換
        //let dateUnix: TimeInterval? = date?.timeIntervalSince1970

//        print(dateUnix)
//        print(String(describing: dateUnix))

        let time = NSDate.timeIntervalSinceReferenceDate

        // Firebase連携
        self.inputData["senderId"] = senderId
        self.inputData["senderDisplayName"] = senderDisplayName
        self.inputData["text"] = text
        self.inputData["timestamp"] = String(time)

        // insert
        let ref = FIRDatabase.database().reference()
        let roomId = userDefaults.string(forKey: DefaultString.Uid)! + (self.petData?.id)!
        let key = ref.child(Paths.MessagePath).child(roomId).childByAutoId().key
//        self.inputData["id"] = key
        ref.child(Paths.MessagePath).child(roomId).child(key).setValue(inputData)

        // update
        ref.child(Paths.UserPath).child(userDefaults.string(forKey: DefaultString.Uid)!).child("messages").updateChildValues([roomId : true])
        ref.child(Paths.PetPath).child(self.petData!.id!).child("messages").updateChildValues([roomId : true])
        //ref.child(Paths.UserPath).child(data.id!).updateChildValues(self.inputData)
//        ref.child(Paths.UserPath).child(self.userData!.id!).child("messages").child("roomId").updateChildValues([key : true])
//        ref.child(Paths.PetPath).child(self.petData!.id!).child("messages").child(roomId).child("messageId").updateChildValues([key : true])
        
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
        print("DEBUG_PRINT: MessagesViewController.didPressAccessoryButton start")

        let viewController4 = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
        viewController4.delegate = self
        self.navigationController?.pushViewController(viewController4, animated: true)

        print("DEBUG_PRINT: MessagesViewController.didPressAccessoryButton end")
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("DEBUG_PRINT: MessagesViewController.imagePickerController start")

        if let image = info[UIImagePickerControllerEditedImage] {
            sendImageMessage(image: image as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)

        print("DEBUG_PRINT: MessagesViewController.imagePickerController end")
    }
    func sendImageMessage(image: UIImage) {
        print("DEBUG_PRINT: MessagesViewController.sendImageMessage start")

        let photoItem = JSQPhotoMediaItem(image: image)
        let imageMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photoItem)
        messages.append(imageMessage!)
        finishSendingMessage(animated: true)
        
        
        let imageData = UIImageJPEGRepresentation(image , 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        print(String(describing: imageMessage?.date))
        let dateUnix: TimeInterval? = imageMessage?.date?.timeIntervalSince1970
        
        // FirebaseにInsert
        self.inputData["senderId"] = senderId
        self.inputData["senderDisplayName"] = senderDisplayName
        self.inputData["imageString"] = imageString
        self.inputData["timestamp"] = dateUnix
        
        // insert
/*        let ref = FIRDatabase.database().reference()
        let key = (self.userData?.id)! + (self.petData?.id)!
        let mid = ref.child(Paths.MessagePath).child(key).child("messages").childByAutoId().key
        ref.child(Paths.MessagePath).child(key).child("messages").child(mid).setValue(inputData)
        
        // update
        ref.child(Paths.UserPath).child(self.userData!.id!).child("messages").updateChildValues(["messageId":key])
        ref.child(Paths.PetPath).child(self.petData!.id!).child("messages").updateChildValues(["messageId":key])
*/
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
    
    //timestampで保存されている投稿時間を年月日に表示形式を変換する
    func getDate(number: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: number)
        //DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        return dateFormatter.string(from: date)
    }
}

extension MessagesViewController: ImageSelectViewDelegate{
    
    func didCompletion(image :UIImage){
        sendImageMessage(image: image)
    }
    
}
