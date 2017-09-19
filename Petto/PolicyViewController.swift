//
//  PolicyViewController.swift
//  Petto
//
//  Created by admin on 2017/09/19.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class PolicyViewController: BaseViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let filePath = Bundle.main.path(forResource: "Policy", ofType: "txt"){
            if let data = NSData(contentsOfFile: filePath){
                textView.text = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
            }else{
                print("データなし")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
