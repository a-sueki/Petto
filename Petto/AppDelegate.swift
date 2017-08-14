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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myNavigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        // Adobeの管理画面で登録したアプリの API key と Client secret の文字列を設定する
        AdobeUXAuthManager.shared().setAuthenticationParametersWithClientID("2643141de91c492087357e553e904699", withClientSecret: "efb2a972-e7a0-4d97-bc5c-084d2e3ddc96")
        
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
               
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

