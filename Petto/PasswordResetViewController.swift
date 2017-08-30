//
//  PasswordResetViewController.swift
//  Petto
//
//  Created by admin on 2017/08/29.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class PasswordResetViewController: UIViewController, UITextFieldDelegate {
    
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: PasswordResetViewController.viewDidLoad start")
        
        
        // textFiel の情報を受け取るための delegate を設定
        mailAddressTextField.delegate = self
        
        if let mail = self.userDefaults.string(forKey: DefaultString.Mail) {
            mailAddressTextField.text = mail
        }
        
        print("DEBUG_PRINT: PasswordResetViewController.viewDidLoad end")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        print("DEBUG_PRINT: PasswordResetViewController.textFieldShouldReturn start")
        
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        print("DEBUG_PRINT: PasswordResetViewController.textFieldShouldReturn end")
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleOkButton(_ sender: Any) {
        print("DEBUG_PRINT: PasswordResetViewController.handleOkButtond start")
        if let address = mailAddressTextField.text {
            
            // アドレスとパスワードのいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty  {
                SVProgressHUD.showError(withStatus: "メールアドレスを入力して下さい")
                return
            }else if isValidEmailAddress(emailAddressString: address) == false {
                SVProgressHUD.showError(withStatus: "メールアドレスが無効です")
                return
            }

            // パスワードの再設定メールを送信する
            FIRAuth.auth()?.sendPasswordReset(withEmail: address) { (error) in
                if let error = error {
                    // HUDで送信失敗を表示する
                    SVProgressHUD.showError(withStatus: "メール送信に失敗しました。")
                    print("DEBUG_PRINT: PasswordResetViewController.handleOkButtond sendPasswordResetでエラー：\(error)")
                }else{
                    // HUDで送信完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "メールを送信しました。")
                }
            }
            // HUDを消す
            SVProgressHUD.dismiss()
            // ログイン画面に遷移
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
            
            print("DEBUG_PRINT: PasswordResetViewController.handleOkButtond end")
        }
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
    
}
