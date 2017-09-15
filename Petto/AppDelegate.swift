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
        print("DEBUG_PRINT: AppDelegate.applicationWillResignActive end")
    }
    // アプリを閉じた時に呼ばれる
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("DEBUG_PRINT: AppDelegate.applicationDidEnterBackground start")
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
    // バックグラウンドで来た通知をタップしてアプリ起動したら呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.didReceive start")
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.didReceive end")
    }
    // アプリがフォアグラウンドの時に通知が来たら呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.willPresent start")

        completionHandler([.alert, .badge, .sound])
        
        print("DEBUG_PRINT: AppDelegate.userNotificationCenter.willPresent end")
    }
}
