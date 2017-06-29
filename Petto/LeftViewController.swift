//
//  LeftViewController.swift
//  Petto
//
//  Created by admin on 2017/06/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

enum LeftMenu: Int {
    case home = 0
    case post
}

class LeftViewController: UIViewController{

    var mainViewController: UINavigationController!
    
    @IBOutlet weak var tableView: UITableView!
    
    var menus = ["Home", "Post"]
    var homeViewController: UIViewController!
    var postViewController: UIViewController!
//    var imageHeaderView: ImageHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.mainViewController = UINavigationController(rootViewController: homeViewController)
        
        let postViewController = storyboard.instantiateViewController(withIdentifier: "Post") as! PostViewController
        self.postViewController = UINavigationController(rootViewController: postViewController)

//        self.tableView.registerCellClass(BaseTableViewCell.self)
        
//        self.imageHeaderView = ImageHeaderView.loadNib()
//        self.view.addSubview(self.imageHeaderView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .home:
            self.slideMenuController()?.changeMainViewController(self.homeViewController, close: true)
        case .post:
            self.slideMenuController()?.changeMainViewController(self.postViewController, close: true)
       }
    }

}
