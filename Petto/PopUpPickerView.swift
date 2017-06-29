import UIKit
import RxSwift
import RxCocoa

public enum PopUpPickerViewStyle
{
    case Default
    case WithSegementedControl
}

class PopUpPickerView: PopUpPickerViewBase {

    var pickerView: UIPickerView!
    lazy var itemSelected: Driver<[Int]> = {
        return self.doneButtonItem.rx.tap.asDriver()
            .map { _ in
                self.hidePicker()
                self.selectedRows = nil
                return self.getSelectedRows()
            }
            .startWith(self.selectedRows ?? [])
    }()
    var segmentedControl: UISegmentedControl?
    private var initSegementedControl: Bool = false
    private let segementedControlHeight: CGFloat = 29
    private let segementedControlSuperViewHeight: CGFloat = 29 + 16

    var delegate: PopUpPickerViewDelegate? {
        didSet {
            pickerView.delegate = delegate
        }
    }
    internal var selectedRows: [Int]?

    // MARK: Initializer
    override init() {
        super.init()
        initFunc()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFunc()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFunc()
    }

    convenience init(rows: [Int], style: PopUpPickerViewStyle = .Default) {
        self.init()
        selectedRows = rows

        if style == .WithSegementedControl {
            let screenSize = UIScreen.main.bounds.size

            let frame = pickerView.frame
            pickerView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + segementedControlSuperViewHeight, width: frame.size.width, height: frame.size.height)

            // MARK:Add board view
            let v = UIView(frame: CGRect(x: 0, y: 44, width: screenSize.width, height: segementedControlSuperViewHeight))
            v.backgroundColor = UIColor.white
            self.addSubview(v)

            let edge = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
            segmentedControl = UISegmentedControl(frame: CGRect(x: edge.left, y:edge.top, width: screenSize.width - (edge.left + edge.right), height: segementedControlHeight) )

            v.addSubview(segmentedControl!)
        }
    }

    private func initFunc() {
        let screenSize = UIScreen.main.bounds.size

        pickerView = UIPickerView()
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor.white
        pickerView.bounds = CGRect(x:0, y:0, width:screenSize.width, height:216)
        pickerView.frame = CGRect(x:0, y:44, width:screenSize.width, height:216)
        self.addSubview(pickerView)
    }

    // MARK: Actions
    override func showPicker() {
        if selectedRows == nil {
            selectedRows = getSelectedRows()
        }
        if let selectedRows = selectedRows {
            for (component, row) in selectedRows.enumerated() {
                pickerView.selectRow(row, inComponent: component, animated: false)
            }
        }
        let screenSize = UIScreen.main.bounds.size
        let segmentedControlHeight: CGFloat = (segmentedControl != nil) ? self.segementedControlSuperViewHeight : 0
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x:0, y:self.parentViewHeight() - (260.0 + segmentedControlHeight), width:screenSize.width, height: 260.0 + segmentedControlHeight)
        }
    }

    override func cancelPicker() {
        hidePicker()
        restoreSelectedRows()
        selectedRows = nil
    }

    override func endPicker() {
        hidePicker()
        delegate?.pickerView?(pickerView: pickerView, didSelect: getSelectedRows())
        selectedRows = nil
    }

    internal func getSelectedRows() -> [Int] {
        var selectedRows = [Int]()
        for i in 0..<pickerView.numberOfComponents {
            selectedRows.append(pickerView.selectedRow(inComponent: i))
        }
        return selectedRows
    }

    private func restoreSelectedRows() {
        guard let selectedRows = selectedRows else { return }
        for i in 0..<selectedRows.count {
            pickerView.selectRow(selectedRows[i], inComponent: i, animated: true)
        }
    }

}

@objc
protocol PopUpPickerViewDelegate: UIPickerViewDelegate {
    @objc optional func pickerView(pickerView: UIPickerView, didSelect numbers: [Int])
}
