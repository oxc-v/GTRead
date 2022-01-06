//
//  GTSexPickerViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/29.
//

import Foundation
import UIKit

class GTSexPickerViewController: GTBaseViewController {
    
    private var pickerView: UIPickerView!
    private var vc: GTAccountDetailInfoTableViewController!
    private let pickerData = ["男", "女"]
    private var accountInfoDataModel: GTAccountInfoDataModel?
    
    init(viewController: GTAccountDetailInfoTableViewController) {
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        self.vc = viewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        // PickerView
        self.setupPickerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 设置默认值
        self.pickerView.selectRow(self.accountInfoDataModel!.male ?? 0, inComponent: 0, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let male = self.pickerView.selectedRow(inComponent: 0)
        if male != self.accountInfoDataModel!.male {
            self.uploadAccountInfo(male: male)
        }
    }
    
    // PickerView
    private func setupPickerView() {
        pickerView = UIPickerView(frame: CGRect.zero)
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        self.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
    }
    
    // 上传信息
    private func uploadAccountInfo(male: Int) {
        DispatchQueue.main.async {
            self.vc.loadingView.isAnimating = true
        }
        GTNet.shared.updateAccountInfo(headImgData: nil, nickName: nil, profile: nil, male: male, age: nil, failure: {e in
            self.vc.loadingView.isAnimating = false
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: {json in
            // 提取数据
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                if dataModel.code == 1 {
                    self.accountInfoDataModel!.male = male
                    GTUserDefault.shared.set(self.accountInfoDataModel, forKey: GTUserDefaultKeys.GTAccountDataModel)
                    NotificationCenter.default.post(name: .GTAccountInfoChanged, object: self)
                    self.showNotificationMessageView(message: "信息修改成功")
                    self.vc.loadingView.isAnimating = false
                } else {
                    self.vc.loadingView.isAnimating = false
                    self.showNotificationMessageView(message: "信息修改失败")
                }
            } else {
                self.vc.loadingView.isAnimating = false
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
}

extension GTSexPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 30
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
        pickerLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        pickerLabel?.text = self.pickerData[row]
        
        return pickerLabel!
    }
}
