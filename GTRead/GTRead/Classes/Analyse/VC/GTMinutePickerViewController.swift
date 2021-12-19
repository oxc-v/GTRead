//
//  GTMinutePickerViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/10.
//

import Foundation
import UIKit

class GTMinutePickerViewController: GTBaseViewController {
    
    var pickerView: UIPickerView!
    var pickerData: [[String]] = [[String]]()
    var timeData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "每日阅读目标"
        self.view.backgroundColor = UIColor(hexString: "#f8f8f9")
        
        pickerView = UIPickerView(frame: CGRect.zero)
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        self.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
        
        for i in 1...1440 {
            timeData.append(String(i))
        }
        pickerData.append(timeData)
        pickerData.append(["分钟/天"])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let minute = UserDefaults.standard.integer(forKey: GTUserDefaultKeys.EveryDayReadTarget.target)
        // 设置默认值
        if minute == 0 {
            pickerView.selectRow(59, inComponent: 0, animated: true)
        } else {
            pickerView.selectRow(minute - 1, inComponent: 0, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let minute = pickerView.selectedRow(inComponent: 0) + 1
        if minute != UserDefaults.standard.integer(forKey: GTUserDefaultKeys.EveryDayReadTarget.target) {
            GTNet.shared.setReadTarget(minute: minute, failure: {json in
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
            }) { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!)
                if dataModel == nil {
                    self.showNotificationMessageView(message: "服务器数据错误")
                } else if dataModel?.code == 1 {
                    // 保存阅读目标
                    UserDefaults.standard.set(minute, forKey: GTUserDefaultKeys.EveryDayReadTarget.target)
                    // 每日阅读目标改变通知
                    NotificationCenter.default.post(name: .GTReadTargetChanged, object: self)
                    
                    DispatchQueue.main.async {
                        self.pickerView.selectRow(minute - 1, inComponent: 0, animated: false)
                    }
                } else {
                    self.showNotificationMessageView(message: "每日阅读目标设置失败")
                }
            }
        }
    }
}

extension GTMinutePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 70
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textColor = .black
            pickerLabel?.textAlignment = .center
        }
        
        if component == 0 {
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        } else {
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        }
        
        pickerLabel?.text = pickerData[component][row]
        
        return pickerLabel!
    }
}
