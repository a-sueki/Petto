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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myNavigationController: UINavigationController?
    let userDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("DEBUG_PRINT: AppDelegate.application start ")

        // UNUserNotificationCenter delegate
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        // Firebase setting
        configureFirebase()
        addRefreshFcmTokenNotificationObserver()
        
        
/*        if FIRApp.defaultApp() == nil {
            FIRApp.configure()
        }
*/
        // Adobeの管理画面で登録したアプリの API key と Client secret の文字列を設定する
        AdobeUXAuthManager.shared().setAuthenticationParametersWithClientID("2643141de91c492087357e553e904699", withClientSecret: "efb2a972-e7a0-4d97-bc5c-084d2e3ddc96")
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            print("DEBUG_PRINT: AppDelegate.application .addStateDidChangeListenerイベントが発生しました")
            if let user = user {
                print("DEBUG_PRINT: AppDelegate.application ユーザ「\(user.uid)」がログイン中")
                self.userDefaults.set(user.uid, forKey: DefaultString.Uid)
                self.userDefaults.set(user.email, forKey: DefaultString.Mail)
                self.userDefaults.set(user.displayName, forKey: DefaultString.DisplayName)
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

        //self.window?.backgroundColor = UIColor.red
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        // ユーザに通知の許可を求める
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization
//        }
//        center.delegate = self;     // 追加
        
        
        print("DEBUG_PRINT: AppDelegate.application end ")
        return true
    }
    
    // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.sound, .alert])
//    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenStr: String = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("APNsトークン: \(deviceTokenStr)")
        
        // APNsトークンを、FCM登録トークンにマッピング
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        
        if let fcmToken = FIRInstanceID.instanceID().token() {
            print("FCMトークン: \(fcmToken)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if #available(iOS 10.0, *) {
        } else {
            FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Called when a notification is delivered to a foreground app.
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called to let your app know which action was selected by the user for a given notification.
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
}
// MARK: - Firebase setting
extension AppDelegate {
    func configureFirebase() {
        #if STAGING_ENV
            let firebasePlistFileName = "Staging-GoogleService-Info"
        #else
            let firebasePlistFileName = "GoogleService-Info"
        #endif
        if let path = Bundle.main.path(forResource: firebasePlistFileName, ofType: "plist") {
            let firebaseOptions: FIROptions = FIROptions(contentsOfFile: path)
            FIRApp.configure(with: firebaseOptions)
        }
    }
    
    func addRefreshFcmTokenNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.fcmTokenRefreshNotification(_:)),
            name: .firInstanceIDTokenRefresh,
            object: nil)
    }
    
    func fcmTokenRefreshNotification(_ notification: Notification) {
        if let refreshedFcmToken = FIRInstanceID.instanceID().token() {
//            print("FCMトークン: \(fcmToken)")
        }
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error: Error?) in
            if let error = error {
                print(error)
                return
            }
        }
    }
}

