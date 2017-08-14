//
//  ConditionsCollectionViewCell.swift
//  Petto
//
//  Created by admin on 2017/08/09.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class ConditionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //表示される時の値をセット
    func setPetData(key: String, codeList: [String]) {
        
        //TODO: textからiconをセット
/*        self.iconImageView.image = UIImage(named: iconImageString)
        self.textLabel.text = text
        if red {
            self.iconImageView.image = UIImage(named: iconImageString)
            self.textLabel.textColor = UIColor.red
        }
 */
    }
}
