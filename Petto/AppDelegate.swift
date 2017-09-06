//
//  AppDelegate.swift
//  Petto
//
//  Created by admin on 2017/06/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate{

    var window: UIWindow?
    var myNavigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("DEBUG_PRINT: AppDelegate.didFinishLaunchingWithOptions start ")

        // FireBase setup
        FIRApp.configure()
        
        // Register APNs
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: { (granted, error) in
                if error != nil {
                    return
                }
                if granted {
                    print("通知許可")
                    UNUserNotificationCenter.current().delegate = self
                } else {
                    print("通知拒否")
                }
            })
        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        
        // Adobeの管理画面で登録したアプリの API key と Client secret の文字列を設定する
        AdobeUXAuthManager.shared().setAuthenticationParametersWithClientID("2643141de91c492087357e553e904699", withClientSecret: "efb2a972-e7a0-4d97-bc5c-084d2e3ddc96")
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            print("DEBUG_PRINT: AppDelegate.application .addStateDidChangeListenerイベントが発生しました")
            if let user = user {
                print("DEBUG_PRINT: AppDelegate.application ユーザ「\(user.uid)」がログイン中")
                // ユーザーデフォルト設定（アカウント項目）
                UserDefaults.standard.set(user.uid , forKey: DefaultString.Uid)
                UserDefaults.standard.set(user.email, forKey: DefaultString.Mail)
                UserDefaults.standard.set(user.displayName, forKey: DefaultString.DisplayName)
            } else {
                print("DEBUG_PRINT: AppDelegate.application ユーザはログインしていません")
            }
        }
        
        // SlideMenu設定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "Left") as! LeftViewController
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: homeViewController)
        leftViewController.mainViewController = nvc
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)

        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        UIView.transition(with: self.window!,
                          duration: 0.6,
                          options: UIViewAnimationOptions.transitionFlipFromLeft,
                          animations: {},
                          completion: {(b) in })

        print("DEBUG_PRINT: AppDelegate.didFinishLaunchingWithOptions end")
        return true
    }
    
    // アプリ閉じそうな時に呼ばれる
    func applicationWillResignActive(_ application: UIApplication) {
        print("DEBUG_PRINT: AppDelegate.applicationWillResignActive start")
        
        
        
        //　通知設定に必要なクラスをインスタンス化
        let trigger: UNNotificationTrigger
        let content = UNMutableNotificationContent()
        var notificationTime = DateComponents()
        
        // トリガー設定
        notificationTime.hour = 12
        notificationTime.minute = 52
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        
        // 通知内容の設定
        content.title = ""
        content.body = "食事の時間になりました！"
        content.sound = UNNotificationSound.default()
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        
        print("DEBUG_PRINT: AppDelegate.applicationWillResignActive end")
    }
    // アプリを閉じた時に呼ばれる
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("DEBUG_PRINT: AppDelegate.applicationDidEnterBackground start")

        
        
        
        //　通知設定に必要なクラスをインスタンス化
        let trigger: UNNotificationTrigger
        let content = UNMutableNotificationContent()
        var notificationTime = DateComponents()
        
        // トリガー設定
        notificationTime.hour = 12
        notificationTime.minute = 51
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        
        // 通知内容の設定
        content.title = ""
        content.body = "食事の時間になりました！"
        content.sound = UNNotificationSound.default()
        
        // 通知スタイルを指定
        let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        print("DEBUG_PRINT: AppDelegate.applicationDidEnterBackground end")
    }
    // アプリを開きそうな時に呼ばれる
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("DEBUG_PRINT: AppDelegate.applicationWillEnterForeground start")
        print("DEBUG_PRINT: AppDelegate.applicationWillEnterForeground end")
    }
    // アプリを開いた時に呼ばれる
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("DEBUG_PRINT: AppDelegate.applicationDidBecomeActive start")
        print("DEBUG_PRINT: AppDelegate.applicationDidBecomeActive end")
    }
    // フリックしてアプリを終了させた時に呼ばれる
    func applicationWillTerminate(_ application: UIApplication) {
        print("DEBUG_PRINT: AppDelegate.applicationWillTerminate start")
        print("DEBUG_PRINT: AppDelegate.applicationWillTerminate end")
    }
}
