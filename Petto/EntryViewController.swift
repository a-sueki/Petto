//
//  EntryViewController.swift
//  Petto
//
//  Created by admin on 2017/07/14.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Eureka


class EntryViewController: FormViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
            }
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
            +++ Section("Section2")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
