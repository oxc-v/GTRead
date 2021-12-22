//
//  GTAccountChangePwdTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/30.
//

import Foundation
import UIKit

class GTAccountUpdatePwdTableViewController: GTTableViewController {
    
    private var cancelBtn: UIButton!
    private var updateBtn: UIButton!
    private var loadingView: GTLoadingView!
    
    private var loginErrLab: UILabel!
    private var oldPwdTextfield: UITextField?
    private var newPwdTextfield: UITextField?
    private var newPwdSubTextfield: UITextField?
    private var oldPwdStr: NSString = ""
    private var newPwdStr: NSString = ""
    private var newPwdSubStr: NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
    }
    
    // TableView
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(GTAccountLoginTableViewCell.self, forCellReuseIdentifier: "GTAccountLoginTableViewCell")
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.systemBlue, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClicked), for: .touchUpInside)
        let leftItems = [UIBarButtonItem(customView: cancelBtn)]
        self.navigationItem.leftBarButtonItems = leftItems
        
        updateBtn = UIButton()
        updateBtn.setTitle("提交", for: .normal)
        updateBtn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .disabled)
        updateBtn.setTitleColor(.systemBlue, for: .normal)
        updateBtn.addTarget(self, action: #selector(updateBtnDidClicked), for: .touchUpInside)
        let rightItems = [UIBarButtonItem(customView: updateBtn)]
        self.navigationItem.rightBarButtonItems = rightItems
        updateBtn.isEnabled = false
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    }
    
    // cancelBtn clicked
    @objc private func cancelBtnDidClicked() {
        self.dismiss(animated: true)
    }
    
    // 控制加载动画的显示
    private func showLoadingView(_ show: Bool) {
        if show {
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: loadingView))
            loadingView.isAnimating = true
        } else {
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: updateBtn))
            loadingView.isAnimating = false
        }
    }
    
    // updateBtn clicked
    @objc private func updateBtnDidClicked() {
        
        self.showLoadingView(true)
        
        let pwd = (UserDefaults.standard.string(forKey: GTUserDefaultKeys.GTAccountPassword))!
        if pwd != (self.oldPwdTextfield?.text)! {
            self.showLoadingView(false)
            self.loginErrLab.text = "密码验证失败"
            self.loginErrLab.clickedAnimation(withDuration: 0.2, completion: nil)
        } else if self.newPwdStr != self.newPwdSubStr {
            self.showLoadingView(false)
            self.loginErrLab.text = "两次输入的新密码不一致"
            self.loginErrLab.clickedAnimation(withDuration: 0.2, completion: nil)
        } else if pwd == (self.newPwdTextfield?.text)! {
            self.showLoadingView(false)
            self.loginErrLab.text = "不能使用旧的密码作为新密码"
            self.loginErrLab.clickedAnimation(withDuration: 0.2, completion: nil)
        } else {
            GTNet.shared.updatePassword(pwd: (self.newPwdTextfield?.text)!, failure: {json in
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
                self.showLoadingView(false)
            }, success: {json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                    if dataModel.code == -1 {
                        self.showLoadingView(false)
                        self.loginErrLab.text = dataModel.errorRes!
                        self.loginErrLab.clickedAnimation(withDuration: 0.2, completion: nil)
                    } else {
                        // 删除用户配置信息
                        let userDefaults = UserDefaults.standard
                        for key in userDefaults.dictionaryRepresentation() {
                            userDefaults.removeObject(forKey: key.key)
                        }
                        userDefaults.synchronize()
                        
                        // 发送退出登录通知
                        NotificationCenter.default.post(name: .GTExitAccount, object: self)
                        
                        self.dismiss(animated: true)
                    }
                } else {
                    self.showNotificationMessageView(message: "服务器数据错误")
                }
                
                self.showLoadingView(false)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        
        let titleLabel = UILabel()
        titleLabel.text = "修改您的密码"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 33)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
        }
        
        let subLabel = UILabel()
        self.loginErrLab = subLabel
        subLabel.font = UIFont.systemFont(ofSize: 17)
        subLabel.textColor = .systemRed
        subLabel.textAlignment = .center
        contentView.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        return contentView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            cell.textfield.delegate = self
            cell.textfield.placeholder = "当前密码"
            cell.textfield.isSecureTextEntry = true
            cell.textfield.returnKeyType = .next
            cell.textfield.enablesReturnKeyAutomatically = true
            self.oldPwdTextfield = cell.textfield
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            cell.textfield.delegate = self
            cell.textfield.placeholder = "新的密码"
            cell.textfield.isSecureTextEntry = true
            cell.textfield.returnKeyType = .next
            cell.textfield.enablesReturnKeyAutomatically = true
            self.newPwdTextfield = cell.textfield
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            cell.textfield.delegate = self
            cell.textfield.placeholder = "确认新的密码"
            cell.textfield.isSecureTextEntry = true
            cell.textfield.returnKeyType = .done
            cell.textfield.enablesReturnKeyAutomatically = true
            self.newPwdSubTextfield = cell.textfield
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension GTAccountUpdatePwdTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 清除提示信息
        self.loginErrLab.text = ""
        
        if self.oldPwdTextfield == textField {
            oldPwdStr = (self.oldPwdTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        } else if self.newPwdTextfield == textField {
            newPwdStr = (self.newPwdTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        } else if self.newPwdSubTextfield == textField {
            newPwdSubStr = (self.newPwdSubTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        }
        
        if oldPwdStr != "" && newPwdStr != "" && newPwdSubStr != "" {
            self.updateBtn.isEnabled = true
        } else {
            self.updateBtn.isEnabled = false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.oldPwdTextfield == textField {
            textField.resignFirstResponder()
            self.newPwdTextfield?.becomeFirstResponder()
        } else if self.newPwdTextfield == textField {
            textField.resignFirstResponder()
            self.newPwdSubTextfield?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.updateBtnDidClicked()
        }
        
        return true
    }
}

