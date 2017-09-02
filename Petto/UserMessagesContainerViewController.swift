//
//  UserMessagesContainerViewController.swift
//  Petto
//
//  Created by admin on 2017/09/02.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class UserMessagesContainerViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    
    var roomData: RoomData?
    var messageData: MessageData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toUserMessages" {
            let messagesViewController:MessagesViewController = segue.destination as! MessagesViewController
            messagesViewController.roomData = self.roomData
        }
        
    }

}
