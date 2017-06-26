//
//  ContainerViewController.swift
//  Petto
//
//  Created by admin on 2017/06/24.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class ContainerViewController: SlideMenuController {
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Main") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Left") {
            self.leftViewController = controller
        }
        super.awakeFromNib()
    }
    
}
