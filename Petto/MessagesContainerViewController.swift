//
//  MessagesContainerViewController.swift
//  Petto
//
//  Created by admin on 2017/08/28.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class MessagesContainerViewController: UIViewController {
    
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
        
        if segue.identifier == "toMessages" {
            let messagesViewController:MessagesViewController = segue.destination as! MessagesViewController
            messagesViewController.roomData = self.roomData
         }
        
    }
    
}
