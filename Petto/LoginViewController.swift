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
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: LoginViewController.viewDidLoad start")
        
        // textFiel の情報を受け取るための delegate を設定
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
        if let mail = self.userDefaults.string(forKey: DefaultString.Mail) {
            mailAddressTextField.text = mail
        }
        if let pass = self.userDefaults.string(forKey: DefaultString.Password) {
            passwordTextField.text = pass
        }
        
        print("DEBUG_PRINT: LoginViewController.viewDidLoad end")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        print("DEBUG_PRINT: LoginViewController.textFieldShouldReturn start")
        
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        print("DEBUG_PRINT: LoginViewController.textFieldShouldReturn end")
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func handleLoginButton(_ sender: Any) {
        print("DEBUG_PRINT: LoginViewController.handleLoginButton start")
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "ログイン情報を入力して下さい")
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
                    // 画面を閉じる
                    self.dismiss(animated: true, completion: nil)
                    // Homeに画面遷移
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
                    self.navigationController?.pushViewController(homeViewController, animated: true)
                    
                }
            }
        }
        
        print("DEBUG_PRINT: LoginViewController.handleLoginButton end")
    }
    
    @IBAction func handleCreateAcountButton(_ sender: Any) {
        print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton start")
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワードのいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "メールアドレスとパスワードを入力して下さい")
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
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                // デフォルト値
                self.userDefaults.set(uid! , forKey: DefaultString.Uid)
                self.userDefaults.set(address , forKey: DefaultString.Mail)
                self.userDefaults.set(password , forKey: DefaultString.Password)
                self.userDefaults.set("ゲストさん" , forKey: DefaultString.DisplayName)
                let imageData = UIImageJPEGRepresentation(UIImage(named: "user")! , 0.5)
                let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
                self.userDefaults.set(imageString , forKey: DefaultString.Phote)
                
                //TODO:確認メール送信
                //FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                // ...
                //})
                
                //TODO:パスワードの再設定メール送信
                //FIRAuth.auth()?.sendPasswordReset(withEmail: userInput) { (error) in
                // ...
                //})
                
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
                        // 画面を閉じてViewControllerに戻る
                        self.dismiss(animated: true, completion: nil)
                        
                        // Homeに画面遷移
                        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
                        self.navigationController?.pushViewController(homeViewController, animated: true)
                        
                    }
                } else {
                    print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton displayNameの設定に失敗しました。")
                }
                
            }
        }
        print("DEBUG_PRINT: LoginViewController.handleCreateAcountButton end")
    }
}
