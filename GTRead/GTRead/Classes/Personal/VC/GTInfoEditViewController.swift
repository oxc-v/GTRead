//
//  GTInfoEditViewContrlloer.swift
//  GTRead
//
//  Created by Dev on 2021/11/6.
//

import UIKit

class GTInfoEditViewController: GTBaseViewController {
    
    var textView: UITextView!
    var saveButton: UIButton!
    var label: UILabel!
    var sizeLabel: UILabel!
    var placeholder: String
    var navTitle: String
    var contentView: UIView!
    var editType: Int
    
    // editType: 0表示编辑昵称、1表示编辑个性签名
    init(title: String, text: String, editType: Int) {
        placeholder = text
        navTitle = title
        self.editType = editType
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.title = navTitle
        
        saveButton = UIButton()
        saveButton.isHidden = true
        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(UIColor(hexString: "#157dfb"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonDidClicked), for: .touchUpInside)
        let rightItems = [UIBarButtonItem(customView: saveButton)]
        self.navigationItem.rightBarButtonItems = rightItems
        
        contentView = UIView()
        contentView.backgroundColor = UIColor(hexString: "#f2f2f7")
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(80)
        }
        
        textView = UITextView()
        textView.text = placeholder
        textView.textColor = .lightGray
        textView.layer.borderWidth = 0.1
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .white
        textView.delegate = self
        self.contentView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(32)
            make.height.equalTo(editType == 0 ? 45 : 120)
        }
        
        label = UILabel()
        label.textAlignment = .left
        label.text = editType == 0 ? "不能使用敏感词库和非法昵称（20字符内）" : "一句话介绍自己（50字符内）"
        label.textColor = UIColor(hexString: "#b4b4b4")
        label.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(textView.snp.left)
            make.top.equalTo(textView.snp.bottom).offset(10)
        }
        
        sizeLabel = UILabel()
        sizeLabel.textAlignment = .center
        sizeLabel.text = editType == 0 ? "0/20" : "0/50"
        sizeLabel.textColor = UIColor(hexString: "#b4b4b4")
        sizeLabel.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(textView.snp.right).offset(-10)
            make.top.equalTo(textView.snp.bottom).offset(10)
        }
    }
    
    // 保存修改的信息
    @objc func saveButtonDidClicked() {
        self.showActivityIndicatorView()
        
        var nickName: String?
        var profile: String?
        if self.editType == 0 {
            nickName = textView.text
        } else {
            profile = textView.text
        }
        GTNet.shared.updateAccountInfo(headImgData: nil, nickName: nickName, profile: profile, male: nil, age: nil, failure: {e in
            if GTNet.shared.networkAvailable() {
                self.hideActivityIndicatorView()
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: {json in
            self.view.endEditing(false)
            
            // 提取数据
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                if dataModel.code == 1 {
                    // 账户信息修改成功通知
                    NotificationCenter.default.post(name: .GTAccountInfoChanged, object: self)
                    self.showNotificationMessageView(message: "修改成功")
                } else {
                    self.view.becomeFirstResponder()
                    self.showNotificationMessageView(message: "修改失败")
                }
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
            self.hideActivityIndicatorView()
        })
    }
}

extension GTInfoEditViewController: UITextViewDelegate {
    // 限制字符数量
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = editType == 0 ? 20 : 50
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        // 不能保存空字符
        if newText.count == 0 {
            self.saveButton.isHidden = true
        } else {
            self.saveButton.isHidden = false
        }
        
        sizeLabel.text = String(newText.count > maxLength ? maxLength : newText.count) + "/" + String(maxLength)
        
        return newText.count <= maxLength
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
        
        if editType == 0 {
            textView.centerVerticalText()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }
}
