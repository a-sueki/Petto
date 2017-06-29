//
//  PopUpDatePickerView.swift
//  AITravel-iOS
//
//  Created by 村田 佑介 on 2016/06/27.
//  Copyright © 2016年 Best10, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PopUpDatePickerView: PopUpPickerViewBase {

    let pickerView: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .date
        p.backgroundColor = UIColor.white
        return p
    }()

    lazy var itemSelected: Driver<NSDate?> = {
//        return self.doneButtonItem.rx_tap.asDriver()
        return self.doneButtonItem.rx.tap.asDriver()
            .map { [unowned self] _ in
                self.hidePicker()
                return self.pickerView.date
            }
            .startWith(self.pickerView.date)
    }()

    // MARK: Initializer
    override init() {
        super.init()
        initFunc()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFunc()
    }

    convenience init(min: NSDate?, max: NSDate?, initial: NSDate?) {
        self.init()
        pickerView.minimumDate = min! as Date
        pickerView.maximumDate = max! as Date
        if let initial = initial {
            pickerView.date = initial as Date
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFunc()
    }

    private func initFunc() {
        let screenSize = UIScreen.main.bounds.size
        pickerView.bounds = CGRect(x:0, y:0, width:screenSize.width, height:216)
        pickerView.frame = CGRect(x:0,  y:44, width:screenSize.width, height:216)

        self.addSubview(pickerView)
    }

    // MARK: Actions
    override func showPicker() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x:0, y:self.parentViewHeight() - 260.0, width:screenSize.width, height:260.0)
        }
    }

    override func cancelPicker() {
        hidePicker()
    }

    override func endPicker() {
        hidePicker()
    }

}
