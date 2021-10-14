//
//  GTPersonalViewController.swift
//  GTRead
//
//  Created by Dev on 2021/9/26.
//

import UIKit
import MJRefresh
import PKHUD

class GTPersonalViewController: GTBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var cellFirstRowHeight = 110
    var cellOtherRowHeight = 70
    let cellInfo = [["登录"], ["消息", "最近浏览"], ["换肤", "夜间模式"], ["设置"]]
    let cellImg = [["profile"], ["info", "browse"], ["skin", "night"], ["setting"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "个人"
        self.view.backgroundColor = UIColor.white

        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GTPersonalViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let header = MJRefreshNormalHeader()
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("释放更新", for: .pulling)
        header.setTitle("正在刷新...", for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh(refreshControl:)))
        tableView.mj_header = header
        tableView.mj_header?.beginRefreshing()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // 下拉刷新操作
    @objc func refresh(refreshControl: UIRefreshControl) {
        let timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { timer in
            refreshControl.endRefreshing()
            self.showWarningAlertController(message: "")
        }

        // 获取用户个人信息
        GTNet.shared.getPersonalInfo() {(json) in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try! decoder.decode(GTPersonalInfoModel.self, from: data!)

            // 更新cell
            let indexPath = IndexPath(item: 0, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.textLabel?.text = dataModel.nickName
            cell?.detailTextLabel?.text = dataModel.profile
            cell?.imageView?.sd_setImage(with: URL(string: dataModel.headImgUrl), placeholderImage: UIImage(named: self.cellImg[0][0]))
            self.tableView.rectForRow(at: indexPath)

            // 保存数据
            UserDefaults.standard.set(dataModel.headImgUrl, forKey: UserDefaultKeys.AccountInfo.imgUrl)
            UserDefaults.standard.set(dataModel.nickName, forKey: UserDefaultKeys.AccountInfo.nickname)

            self.tableView.mj_header?.endRefreshing()
            timer.invalidate()
        }
    }
    
    // 退出登录重置信息
    func resetPersonalInfo() {
        // 更新cell
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.textLabel?.text = cellInfo[0][0]
        cell?.imageView?.image = UIImage(named: self.cellImg[0][0])
        self.tableView.rectForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(cellFirstRowHeight)
        } else {
            return CGFloat(cellOtherRowHeight)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfo[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPersonalViewCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = cellInfo[indexPath.section][indexPath.row]
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = cell.imageView?.frame.width ?? 0 / 2

        if indexPath.section == 0 {
            cell.accessoryType = .none
            cell.imageView?.sd_setImage(with: URL(string: UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.imgUrl) ?? ""), placeholderImage: UIImage(named: cellImg[0][0]))
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: cellImg[indexPath.section][indexPath.row])
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if UserDefaults.standard.bool(forKey: UserDefaultKeys.LoginStatus.isLogin) == false {
                showActionSheetController()
            }
        } else if indexPath.section == 3 {
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(GTPersonalSettingViewController(viewController: self), animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }

    // 显示按钮弹窗
    func showActionSheetController() {
        let alertController = UIAlertController(title: "账号", message: "登录或注册一个账号", preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "登录", style: .default) {
                    (action: UIAlertAction!) -> Void in
            self.showLoginAlertController()
        }
        let registerAction = UIAlertAction(title: "注册", style: .default) {
                    (action: UIAlertAction!) -> Void in
            self.showRegisterAlertController()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alertController.addAction(loginAction)
        alertController.addAction(registerAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // 显示登录弹窗
    func showLoginAlertController(message: String = "登录以管理您的账号") {
        let alertController = UIAlertController(title: "登录", message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "账号"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "密码"
            textField.isSecureTextEntry = true
        }
        let okAction = UIAlertAction(title: "登录", style: UIAlertAction.Style.default) { (action: UIAlertAction!) -> Void in
            // 加载动画
            HUD.show(.labeledProgress(title: "登录中...", subtitle: ""))
            HUD.hide(afterDelay: 6, completion: {_ in
                self.showWarningAlertController(message: "登录失败")
            })
            
            let account = alertController.textFields!.first!
            let password = alertController.textFields!.last!
            GTNet.shared.requestLogin(userId: account.text ?? "", userPwd: password.text ?? "") { (json) in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                let dataModel = try! decoder.decode(GTPersonalRegisterModel.self, from: data!)

                if dataModel.code == -1 {
                    self.showLoginAlertController(message: dataModel.errorRes!)
                } else {
                    UserDefaults.standard.set(account.text, forKey: UserDefaultKeys.AccountInfo.account)
                    UserDefaults.standard.set(password.text, forKey: UserDefaultKeys.AccountInfo.password)
                    UserDefaults.standard.set(true, forKey: UserDefaultKeys.LoginStatus.isLogin)
                    self.tableView.mj_header?.beginRefreshing()
                }
                
                // 关闭加载动画
                HUD.hide()
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // 显示注册弹窗
    func showRegisterAlertController(message: String = "注册一个新账号") {
        let alertController = UIAlertController(title: "注册", message: message, preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "账号"
            textField.keyboardType = .asciiCapableNumberPad;
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "密码"
            textField.isSecureTextEntry = true
            textField.keyboardType = .asciiCapableNumberPad;
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "确认密码"
            textField.isSecureTextEntry = true
            textField.keyboardType = .asciiCapableNumberPad;
        }
        let account = alertController.textFields![0]
        let password_1 = alertController.textFields![1]
        let password_2 = alertController.textFields![2]

        let registerAction = UIAlertAction(title: "注册", style: .destructive) { (action: UIAlertAction!) -> Void in
            if password_1.text != password_2.text {
                self.showRegisterAlertController(message: "两次输入的密码不一致")
            } else {
                // 加载动画
                HUD.show(.labeledProgress(title: "注册中...", subtitle: ""))
                HUD.hide(afterDelay: 6, completion: {_ in
                    self.showWarningAlertController(message: "注册失败")
                })

                // 注册请求
                GTNet.shared.requestRegister(userId: account.text ?? "", userPwd: password_2.text ?? "") { json in
                    // 提取数据
                    let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                    let decoder = JSONDecoder()
                    let dataModel = try! decoder.decode(GTPersonalRegisterModel.self, from: data!)
                    if dataModel.code == -1 {
                        self.showRegisterAlertController(message: dataModel.errorRes!)
                    } else {
                        UserDefaults.standard.set(account.text, forKey: UserDefaultKeys.AccountInfo.account)
                        UserDefaults.standard.set(password_2.text, forKey: UserDefaultKeys.AccountInfo.password)
                        UserDefaults.standard.set(true, forKey: UserDefaultKeys.LoginStatus.isLogin)
                        self.tableView.mj_header?.beginRefreshing()
                    }

                    // 关闭加载动画
                    HUD.hide()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(registerAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    // 提示框
    func showWarningAlertController(message: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func isPurnInt(string: String) -> Bool {
        let scan: Scanner = Scanner(string: string)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
     
    }
}
