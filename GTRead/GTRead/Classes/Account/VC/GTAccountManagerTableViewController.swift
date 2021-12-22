//
//  GTAccountManagerTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/27.
//

import Foundation
import UIKit
import SDWebImage

class GTAccountManagerTableViewController: GTTableViewController {
    
    private var finishedBtn: UIButton!
    private var loadingView: GTLoadingView!
    
    private var accountInfoDataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
    
    private var accountTextfield: UITextField?
    private var passwordTextfield: UITextField?
    private var loginErrorBtn: UIButton?
    private var accountStr: NSString = ""
    private var passwordStr: NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
        
        // 注册账户信息修改的通知
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableviewData), name: .GTAccountInfoChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "账户"
        
        finishedBtn = UIButton(type: .custom)
        finishedBtn.setTitle("完成", for: .normal)
        finishedBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        finishedBtn.setTitleColor(.systemBlue, for: .normal)
        finishedBtn.addTarget(self, action: #selector(finishedBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishedBtn)

        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadingView)
    }
    
    // TableView
    private func setupTableView() {
        tableView.register(GTAccountManagerTextFieldTableViewCell.self, forCellReuseIdentifier: "GTAccountManagerTextFieldTableViewCell")
        tableView.register(GTAccountManagerCommonTableViewCell.self, forCellReuseIdentifier: "GTAccountManagerCommonTableViewCell")
        tableView.register(GTAccountManagerButtonTableViewCell.self, forCellReuseIdentifier: "GTAccountManagerButtonTableViewCell")
        tableView.register(GTAccountManagerImgTableViewCell.self, forCellReuseIdentifier: "GTAccountManagerImgTableViewCell")
    }
    
    // 更新TableView数据
    @objc private func reloadTableviewData() {
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        self.tableView.reloadData()
    }
    
    // finishedBtn clicked
    @objc private func finishedBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // 清除缓存提示框
    private func showClearDiskCacheAlert() {
        let alertController = UIAlertController(title: "确定要清除缓存么？", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .destructive) {
                    (action: UIAlertAction!) -> Void in
            GTDiskCache.shared.clearCache()
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 处理退出登录按钮点击事件
    @objc private func exitAccountBtnDidClicked(sender: UIButton) {
        // 删除用户配置信息
        let userDefaults = UserDefaults.standard
        for key in userDefaults.dictionaryRepresentation() {
            userDefaults.removeObject(forKey: key.key)
        }
        userDefaults.synchronize()
        
        self.dismiss(animated: true)
        
        // 发送退出登录通知
        NotificationCenter.default.post(name: .GTExitAccount, object: self)
    }
    
    // 处理注册按钮点击事件
    @objc private func registerBtnDidClicked(sender: UIButton) {
        // 发送打开注册视图通知
        NotificationCenter.default.post(name: .GTOpenRegisterView, object: self)
    }
    
    // 处理登录请求
    @objc private func loginBtnDidClicked() {
        self.loadingView.isAnimating = true
        GTNet.shared.requestLogin(userId: self.accountTextfield?.text ?? "", userPwd: self.passwordTextfield?.text ?? "", failure: {json in
            self.loadingView.isAnimating = false
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { (json) in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTPersonalRegisterModel.self, from: data!) {
                if dataModel.code == -1 {
                    self.loadingView.isAnimating = false
                    self.loginErrorBtn?.setTitle("账号或密码错误", for: .normal)
                    self.loginErrorBtn?.clickedAnimation(withDuration: 0.2, completion: nil)
                } else {
                    // ----此处需要完善 记得暂停加载动画
                    UserDefaults.standard.set(self.passwordTextfield?.text, forKey: GTUserDefaultKeys.GTAccountPassword)
                    self.getAccountInfo(userId: (self.accountTextfield?.text)!)
                }
            } else {
                self.loadingView.isAnimating = false
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    // -----此处将来需要完善 请求获取账户信息
    private func getAccountInfo(userId: String) {
        GTNet.shared.getAccountInfo(userId: userId, failure: { json in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
            self.loadingView.isAnimating = false
        }, success: {json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTAccountInfoDataModel.self, from: data!) {
                self.accountInfoDataModel = dataModel
                GTUserDefault.shared.set(self.accountInfoDataModel, forKey: GTUserDefaultKeys.GTAccountDataModel)
                NotificationCenter.default.post(name: .GTLoginSuccessful, object: self)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
            
            self.loadingView.isAnimating = false
        })
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.accountInfoDataModel != nil {
            if indexPath.section == 0 {
                return 70
            }
        }
        return 50.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.accountInfoDataModel != nil {
            return 4
        } else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.accountInfoDataModel != nil {
            return 1
        } else {
            switch section {
            case 0:
                return 2
            case 1:
                return 2
            default:
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.accountInfoDataModel != nil {
            return nil
        } else {
            if section == 0 {
                let btn = UIButton()
                btn.setTitleColor(.systemRed, for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                loginErrorBtn = btn
                return btn
            } else if section == 1 {
                let btn = UIButton()
                btn.setTitle("忘记账号或密码？", for: .normal)
                btn.setTitleColor(.systemBlue, for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                return btn
            } else {
                return nil
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.accountInfoDataModel != nil {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerImgTableViewCell", for: indexPath) as! GTAccountManagerImgTableViewCell
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.imgView.sd_setImage(with: URL(string: self.accountInfoDataModel?.headImgUrl ?? ""), placeholderImage: UIImage(named: self.accountInfoDataModel!.male ? "head_men" : "head_women"))
                cell.nameLabel.text = self.accountInfoDataModel?.nickName
                cell.profileLabel.text = self.accountInfoDataModel?.profile
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
                cell.titleLabel.text = "账户安全"
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
                cell.titleLabel.text = "清除缓存"
                cell.detailLabel.text = String(format: "%.1f", GTDiskCache.shared.fileSizeOfCache()) + "M"
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerButtonTableViewCell", for: indexPath) as! GTAccountManagerButtonTableViewCell
                cell.selectionStyle = .none
                cell.btn.setTitle("退出登录", for: .normal)
                cell.btn.setTitleColor(.systemRed, for: .normal)
                cell.btn.addTarget(self, action: #selector(exitAccountBtnDidClicked(sender:)), for: .touchUpInside)
                return cell
            }
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerTextFieldTableViewCell", for: indexPath) as! GTAccountManagerTextFieldTableViewCell
                cell.selectionStyle = .none
                cell.textField.delegate = self
                cell.textField.enablesReturnKeyAutomatically = true
                if indexPath.row == 0 {
                    cell.titleLabel.text = "账户"
                    cell.textField.placeholder = "账户"
                    cell.textField.returnKeyType = .next
                    self.accountTextfield = cell.textField
                } else {
                    cell.titleLabel.text = "密码"
                    cell.textField.placeholder = "必填"
                    cell.textField.isSecureTextEntry = true
                    cell.textField.returnKeyType = .done
                    self.passwordTextfield = cell.textField
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerButtonTableViewCell", for: indexPath) as! GTAccountManagerButtonTableViewCell
                cell.selectionStyle = .none
                if indexPath.row == 0 {
                    cell.btn.setTitle("登录", for: .normal)
                    cell.btn.addTarget(self, action: #selector(loginBtnDidClicked), for: .touchUpInside)
                    if accountStr != "" && passwordStr != "" {
                        cell.btn.isEnabled = true
                    } else {
                        cell.btn.isEnabled = false
                    }
                    
                } else {
                    cell.btn.setTitle("注册", for: .normal)
                    cell.btn.addTarget(self, action: #selector(registerBtnDidClicked(sender:)), for: .touchUpInside)
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
                cell.titleLabel.text = "清除缓存"
                cell.detailLabel.text = String(format: "%.1f", GTDiskCache.shared.fileSizeOfCache()) + "M"
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.accountInfoDataModel != nil {
            switch indexPath.section {
            case 0:
                let vc = GTAccountDetailInfoTableViewController(style: .insetGrouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = GTAccountSecurityTableViewController(style: .insetGrouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                self.showClearDiskCacheAlert()
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 2:
                self.showClearDiskCacheAlert()
            default:
                break
            }
        }
    }
}

extension GTAccountManagerTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // 清除登录提示信息
        loginErrorBtn?.setTitle("", for: .normal)
        
        if self.accountTextfield == textField {
            accountStr = (self.accountTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        } else if self.passwordTextfield == textField {
            passwordStr = (self.passwordTextfield!.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        
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
