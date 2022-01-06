//
//  GTAccountLoginTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/30.
//

import Foundation
import UIKit

class GTAccountLoginTableViewController: GTTableViewController {
    
    private var cancelBtn: UIButton!
    private var loginBtn: UIButton!
    private var loadingView: GTLoadingView!
    private var loginErrLab: UILabel!
    
    private var accountTextfield: UITextField?
    private var passwordTextfield: UITextField?
    private var accountStr: NSString = ""
    private var passwordStr: NSString = ""
    
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
        
        loginBtn = UIButton()
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .disabled)
        loginBtn.setTitleColor(.systemBlue, for: .normal)
        loginBtn.addTarget(self, action: #selector(loginBtnDidClicked), for: .touchUpInside)
        let rightItems = [UIBarButtonItem(customView: loginBtn)]
        self.navigationItem.rightBarButtonItems = rightItems
        loginBtn.isEnabled = false
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    }
    
    // 控制加载动画的显示
    private func showLoadingView(_ show: Bool) {
        if show {
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: loadingView))
            loadingView.isAnimating = true
        } else {
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: loginBtn))
            loadingView.isAnimating = false
        }
    }
    
    // cancelBtn clicked
    @objc private func cancelBtnDidClicked() {
        self.dismiss(animated: true)
    }
    
    // loginBtn clicked
    @objc private func loginBtnDidClicked() {
        
        self.showLoadingView(true)
        
        // 发起登录请求
        GTNet.shared.requestLogin(userId: Int((self.accountTextfield?.text)!)!, userPwd: self.passwordTextfield?.text ?? "", failure: {json in
            
            self.showLoadingView(false)
            
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { (json) in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                if dataModel.code == -1 {
                    self.showLoadingView(false)
                    self.loginErrLab.text = "账号或密码错误"
                    self.loginErrLab.clickedAnimation(withDuration: 0.2, completion: nil)
                } else {
                    // ----此处需要完善 记得暂停加载动画
                    UserDefaults.standard.set(self.passwordTextfield?.text, forKey: GTUserDefaultKeys.GTAccountPassword)
                    self.getAccountInfo(userId: Int((self.accountTextfield?.text)!)!)
                }
            } else {
                self.showLoadingView(false)
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    // -----此处将来需要完善 请求获取账户信息
    private func getAccountInfo(userId: Int) {
        GTNet.shared.getAccountInfo(userId: userId, failure: { json in
            
            self.showLoadingView(false)
            
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: {json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if var dataModel = try? decoder.decode(GTAccountInfoDataModel.self, from: data!) {
                GTUserDefault.shared.set(dataModel, forKey: GTUserDefaultKeys.GTAccountDataModel)
                
                NotificationCenter.default.post(name: .GTLoginSuccessful, object: self)
                self.dismiss(animated: true)
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
            
            self.showLoadingView(false)
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        
        let titleLabel = UILabel()
        titleLabel.text = "登录您的账号"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 33)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
        }
        
        let subLabel = UILabel()
        self.loginErrLab = subLabel
        subLabel.textColor = .systemRed
        subLabel.font = UIFont.systemFont(ofSize: 17)
        subLabel.textAlignment = .center
        contentView.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        return contentView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let btn = UIButton()
        btn.setTitle("忘记密码？", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            self.accountTextfield = cell.textfield
            cell.textfield.delegate = self
            cell.textfield.placeholder = "账号"
            cell.textfield.becomeFirstResponder()
            cell.textfield.isSecureTextEntry = false
            cell.textfield.returnKeyType = .next
            cell.textfield.enablesReturnKeyAutomatically = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            self.passwordTextfield = cell.textfield
            cell.textfield.delegate = self
            cell.textfield.placeholder = "密码"
            cell.textfield.isSecureTextEntry = true
            cell.textfield.returnKeyType = .done
            cell.textfield.enablesReturnKeyAutomatically = true
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension GTAccountLoginTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 清除提示信息
        self.loginErrLab.text = ""
        
        if self.accountTextfield == textField {
            accountStr = (self.accountTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        } else if self.passwordTextfield == textField {
            passwordStr = (self.passwordTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        }
        
        if accountStr != "" && passwordStr != "" {
            self.loginBtn.isEnabled = true
        } else {
            self.loginBtn.isEnabled = false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.accountTextfield == textField {
            textField.resignFirstResponder()
            self.passwordTextfield?.becomeFirstResponder()
        } else if self.passwordTextfield == textField {
            textField.resignFirstResponder()
            self.loginBtnDidClicked()
        }
        
        return true
    }
}
