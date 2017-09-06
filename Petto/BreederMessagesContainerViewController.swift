//
//  MessagesContainerViewController.swift
//  Petto
//
//  Created by admin on 2017/08/28.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class BreederMessagesContainerViewController: UIViewController {
    
    var roomData: RoomData?
    var messageData: MessageData?
 
    let topViewController: MessagesViewController  // ViewController①を保持
    let underViewController: BookingViewController  // ViewController②を保持
    
    // ContainerViewControllerにViewController①と②をセットするイニシャライザ
    init(top:MessagesViewController, under:BookingViewController){
        print("DEBUG_PRINT: BreederMessagesContainerViewController.init start")

        topViewController = top
        underViewController = under
        
        super.init(nibName:nil, bundle:nil)

        print("DEBUG_PRINT: BreederMessagesContainerViewController.init end")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: BreederMessagesContainerViewController.viewDidLoad start")
        
        // ViewController①をContainerViewControllerの子として追加
        topViewController.roomData = self.roomData
        addChildViewController(topViewController)

        // ViewController①の表示
        view.addSubview(topViewController.view)
        topViewController.didMove(toParentViewController: self)
        topViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
 
        // ViewController②をContainerViewControllerの子として追加
        underViewController.roomData = self.roomData
        addChildViewController(underViewController)
        
        // ViewController②の表示
        view.addSubview(underViewController.view)
        underViewController.didMove(toParentViewController: self)
        underViewController.view.frame = CGRect(x: 0, y: view.frame.height/2, width: view.frame.width, height: view.frame.height/2)
        
        print("DEBUG_PRINT: BreederMessagesContainerViewController.viewDidLoad end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
