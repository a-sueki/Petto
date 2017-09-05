//
//  LoginViewController.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SlideMenuControllerSwift
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: LoginViewController.viewDidLoad start")
        
        // textFiel の情報を受け取るための delegate を設定
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
        if let mail = UserDefaults.standard.string(forKey: DefaultString.Mail) {
            mailAddressTextField.text = mail
        }
        if let pass = UserDefaults.standard.string(forKey: DefaultString.Password) {
            passwordTextField.text = pass
        }
        
        print("DEBUG_PRINT: LoginViewController.viewDidLoad end")
    }
    
    // Returnキーでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        print("DEBUG_PRINT: LoginViewController.textFieldShouldReturn start")
        
        textField.resignFirstResponder()
        
        print("DEBUG_PRINT: LoginViewController.textFieldShouldReturn end")
        return true
    }
    
    // TextField以外の部分をタッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("DEBUG_PRINT: LoginViewController.touchesBegan start")
        
        self.view.endEditing(true)
        
        print("DEBUG_PRINT: LoginViewController.touchesBegan end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func handleLoginButton(_ sender: Any) {
        print("DEBUG_PRINT: LoginViewController.handleLoginButton start")
        
        self.view.endEditing(true)
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "ログイン情報を入力して下さい")
                return
            }else if isValidEmailAddress(emailAddressString: address) == false {
                SVProgressHUD.showError(withStatus: "メールアドレスが無効です")
                return
            }else if password.characters.count < 6 || password.characters.count > 12 {
                SVProgressHUD.showError(withStatus: "パスワードは6〜12文字にして下さい")
                return
            }
            
            FIRAuth.auth()?.signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました")
                    return
                } else {
                    print("DEBUG_PRINT: ログインに成功しました")
                    // HUDを消す
                    SVProgressHUD.dismiss()
                    
                    // Firebaseから登録済みデータを取得
                    if let uid = user?.uid {
                        let ref = FIRDatabase.database().reference().child(Paths.UserPath).child(uid)
                        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                            print("DEBUG_PRINT: LoginViewController.handleLoginButton .observeSingleEventイベントが発生しました。")
                            if let _ = snapshot.value as? NSDictionary {
                                let userData = UserData(snapshot: snapshot, myId: uid)
                                
                                UserDefaults.standard.set(false , forKey: DefaultString.GuestFlag)
                                // ユーザーデフォルト設定（ユーザー項目（必須））
                                UserDefaults.standard.set(userData.imageString , forKey: DefaultString.ImageString)
                                UserDefaults.standard.set(userData.firstname , forKey: DefaultString.Firstname)
                                UserDefaults.standard.set(userData.lastname , forKey: DefaultString.Lastname)
                                UserDefaults.standard.set(userData.birthday , forKey: DefaultString.Birthday)
                                UserDefaults.standard.set(userData.area , forKey: DefaultString.Area)
                                UserDefaults.standard.set(userData.age , forKey: DefaultString.Age)
                                UserDefaults.standard.set(userData.hasAnotherPet , forKey: DefaultString.HasAnotherPet)
                                UserDefaults.standard.set(userData.isExperienced , forKey: DefaultString.IsExperienced)
                                UserDefaults.standard.set(userData.expectTo , forKey: DefaultString.ExpectTo)
                                UserDefaults.standard.set(userData.createAt , forKey: DefaultString.CreateAt)
                                UserDefaults.standard.set(userData.createBy , forKey: DefaultString.CreateBy)
                                UserDefaults.standard.set(userData.updateAt , forKey: DefaultString.UpdateAt)
                                UserDefaults.standard.set(userData.updateBy , forKey: DefaultString.UpdateBy)
                                // ユーザーデフォルト設定（ユーザー項目（任意））
                                if !userData.ngs.isEmpty {
                                    UserDefaults.standard.set(userData.ngs , forKey: DefaultString.Ngs)
                                }
                                if !userData.userEnvironments.isEmpty {
                                UserDefaults.standard.set(userData.userEnvironments , forKey: DefaultString.UserEnvironments)
                                }
                                if !userData.userTools.isEmpty {
                                UserDefaults.standard.set(userData.userTools , forKey: DefaultString.UserTools)
                                }
                                if !userData.userNgs.isEmpty {
                                UserDefaults.standard.set(userData.userNgs , forKey: DefaultString.UserNgs)
                                }
                                if !userData.myPets.isEmpty {
                                UserDefaults.standard.set(userData.myPets , forKey: DefaultString.MyPets)
                                }
                                if !userData.roomIds.isEmpty {
                                UserDefaults.standard.set(userData.roomIds , forKey: DefaultString.RoomIds)
                                }
                                if !userData.unReadRoomIds.isEmpty {
                                UserDefaults.standard.set(userData.unReadRoomIds , forKey: DefaultString.UnReadRoomIds)
                                }
                                if !userData.todoRoomIds.isEmpty {
                                    UserDefaults.standard.set(userData.todoRoomIds , forKey: DefaultString.TodoRoomIds)
                                }
                               if !userData.goods.isEmpty {
                                UserDefaults.standard.set(userData.goods , forKey: DefaultString.Goods)
                                }
                                if !userData.bads.isEmpty {
                                UserDefaults.standard.set(userData.bads , forKey: DefaultString.Bads)
                                }
                            }else{
                                UserDefaults.standard.set(true , forKey: DefaultString.GuestFlag)
                            }
                        })
                    }else{
                        UserDefaults.standard.set(true , forKey: DefaultString.GuestFlag)
                    }
                    
                    // ユーザーデフォルト設定（アカウント項目）
                    UserDefaults.standard.set(user?.uid , forKey: DefaultString.Uid)
                    UserDefaults.standard.set(address , forKey: DefaultString.Mail)
                    UserDefaults.standard.set(password , forKey: DefaultString.Password)
                    UserDefaults.standard.set(user?.displayName , forKey: DefaultString.DisplayName)
                    
                    // Homeに画面遷移
                    DispatchQueue.main.async {
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let leftViewController = self.storyboard?.instantiateViewController(withIdentifier: "Left") as! LeftViewController
                        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
                        
                        let nvc: UINavigationController = UINavigationController(rootViewController: homeViewController)
                        leftViewController.mainViewController = nvc
                        
                        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
                        
                        appDelegate.window?.rootViewController = slideMenuController
                        appDelegate.window?.makeKeyAndVisible()
                        UIView.transition(with: appDelegate.window!,
                                          duration: 0.6,
                                          options: UIViewAnimationOptions.transitionFlipFromLeft,
                                          animations: {},
                                          completion: {(b) in })
                    }
                }
            }
        }
        
        print("DEBUG_PRINT: LoginViewController.handleLoginButton end")
    }
    
    @IBAction func handleCreateAcountButton(_ sender: Any) {
        print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton start")
        
        self.view.endEditing(true)
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "ログイン情報を入力して下さい")
                return
            }else if isValidEmailAddress(emailAddressString: address) == false {
                SVProgressHUD.showError(withStatus: "メールアドレスが無効です")
                return
            }else if password.characters.count < 6 || password.characters.count > 12 {
                SVProgressHUD.showError(withStatus: "パスワードは6〜12文字にして下さい")
                return
            }
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            FIRAuth.auth()?.createUser(withEmail: address, password: password) { user, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton " + error.localizedDescription)
                    if error.localizedDescription == "The email address is already in use by another account." {
                        SVProgressHUD.showError(withStatus: "そのアカウントは既に存在します")
                    } else {
                        SVProgressHUD.showError(withStatus: "メールアドレスかパスワードが無効です")
                    }
                    return
                }
                
                // 確認メール送信
                if let user = FIRAuth.auth()?.currentUser {
                    if !user.isEmailVerified {
                        let alertVC = UIAlertController(title: "仮登録が成功しました", message: "上記アドレスに確認メールを送信しました。\nメール内のURLをクリックし、登録を完了してください。", preferredStyle: .alert)
                        let alertActionOkay = UIAlertAction(title: "OK", style: .default) {
                            (_) in
                            user.sendEmailVerification(completion: nil)
                        }
                        let alertActionCancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                        alertVC.addAction(alertActionOkay)
                        alertVC.addAction(alertActionCancel)
                        self.present(alertVC, animated: true, completion: nil)
                    } else {
                        // HUDで送信完了を表示する
                        SVProgressHUD.showSuccess(withStatus: "アカウントを作成しました")
                    }
                }
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                // ユーザーデフォルト設定（アカウント項目）
                UserDefaults.standard.set(true , forKey: DefaultString.GuestFlag)
                UserDefaults.standard.set(uid! , forKey: DefaultString.Uid)
                UserDefaults.standard.set(address , forKey: DefaultString.Mail)
                UserDefaults.standard.set(password , forKey: DefaultString.Password)
                UserDefaults.standard.set("ゲストさん" , forKey: DefaultString.DisplayName)                
                
                // 表示名を設定する
                let user = FIRAuth.auth()?.currentUser
                if let user = user {
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.displayName = "ゲストさん"
                    changeRequest.commitChanges { error in
                        if let error = error {
                            SVProgressHUD.showError(withStatus: "")
                            print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton " + error.localizedDescription)
                        }
                        print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        // HUDを消す
                        SVProgressHUD.dismiss()
                    }
                } else {
                    print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton displayNameの設定に失敗しました。")
                }
                
            }
        }
        print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton end")
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    @IBAction func handlePasswordResetButton(_ sender: Any) {
        print("DEBUG_PRINT: LoginViewController.handlePasswordResetButton start")

        self.view.endEditing(true)
        // PasswordResetに画面遷移
        let passwordResetViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordReset") as! PasswordResetViewController
        present(passwordResetViewController, animated: true, completion: nil)
        
        print("DEBUG_PRINT: LoginViewController.handlePasswordResetButton end")
    }
}
