//
//  GTPersonalViewController.swift
//  GTRead
//
//  Created by Dev on 2021/9/26.
//

import UIKit
import MJRefresh
import SDWebImage

class GTPersonalViewController: GTBaseViewController {
    
    var tableView: UITableView!
    var cellFirstRowHeight = 110
    var cellOtherRowHeight = 70
    let cellInfo = [["登录"], ["消息", "最近浏览"], ["换肤", "夜间模式"], ["设置"]]
    let cellImg = [["profile"], ["info", "browse"], ["skin", "night"], ["setting"]]
    var dataModel: GTPersonalInfoModel?
    var personalInfoViewContrller: GTPersonalInfoViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "个人"
        self.view.backgroundColor = UIColor(hexString: "#f2f2f7")

        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(GTPersonalViewCell.self, forCellReuseIdentifier: "GTPersonalViewCell")
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
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(70)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 账户信息更改
        NotificationCenter.default.addObserver(self, selector: #selector(notificationForAccountInfChanged), name: .GTAccountInfoChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh(refreshControl: nil)
    }

    // 下拉刷新操作
    @objc func refresh(refreshControl: UIRefreshControl?) {
        if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) != nil {
            // 获取用户信息
            GTNet.shared.getPersonalInfo(failure: { json in
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
                refreshControl?.endRefreshing()
                self.hideActivityIndicatorView()
            }, success: { [self] json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                self.dataModel = try? decoder.decode(GTPersonalInfoModel.self, from: data!)
                if self.dataModel == nil {
                    self.showNotificationMessageView(message: "服务器数据错误")
                }
                
                DispatchQueue.main.async {
                    // 刷新个人信息页的数据
                    // 不使用reloadData是因为要保持detailTextField始终可以获取焦点
                    if self.personalInfoViewContrller != nil {
                        self.personalInfoViewContrller?.dataModel = dataModel
                        let cellHeadImgView = self.personalInfoViewContrller?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! GTPersonalInfoViewCell
                        cellHeadImgView.imgView.sd_setImage(with: URL(string: dataModel?.headImgUrl ?? ""), placeholderImage: UIImage(named: "profile"))
                        let cellNicknameLabel = self.personalInfoViewContrller?.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! GTPersonalInfoViewCell
                        cellNicknameLabel.detailTextField.placeholder = dataModel?.nickName
                        let cellMaleLabel = self.personalInfoViewContrller?.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! GTPersonalInfoViewCell
                        cellMaleLabel.detailTextField.placeholder = dataModel?.male == true ? "男" : "女"
                        let cellProfileLabel = self.personalInfoViewContrller?.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! GTPersonalInfoViewCell
                        cellProfileLabel.detailTextField.placeholder = dataModel?.profile
                    }
                    
                    
                    self.tableView.reloadData()
                }

                refreshControl?.endRefreshing()
                self.hideActivityIndicatorView()
            })
        } else {
            refreshControl?.endRefreshing()
            self.hideActivityIndicatorView()
            self.dataModel = nil
            self.tableView.reloadData()
        }
    }
    
    // 用与响应GTAccountInfoChanged通知
    @objc func notificationForAccountInfChanged() {
        self.refresh(refreshControl: nil)
    }

    // 显示按钮弹窗
    @objc func showActionSheetController() {
        let alertController = UIAlertController(title: "咱要做一个有身份的人哟", message: nil, preferredStyle: .alert)
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
            self.showActivityIndicatorView()
            
            let account = alertController.textFields!.first!
            let password = alertController.textFields!.last!
            GTNet.shared.requestLogin(userId: account.text ?? "", userPwd: password.text ?? "", failure: {json in
                self.hideActivityIndicatorView()
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
                        self.hideActivityIndicatorView()
                        self.showLoginAlertController(message: dataModel.errorRes!)
                    } else {
                        UserDefaults.standard.set(account.text, forKey: UserDefaultKeys.AccountInfo.account)
                        UserDefaults.standard.set(password.text, forKey: UserDefaultKeys.AccountInfo.password)
                        self.refresh(refreshControl: nil)
                    }
                } else {
                    self.hideActivityIndicatorView()
                    self.showNotificationMessageView(message: "服务器数据错误")
                }
            })
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
                self.showActivityIndicatorView()

                // 注册请求
                GTNet.shared.requestRegister(userId: account.text ?? "", userPwd: password_2.text ?? "", failure: { json in
                    self.hideActivityIndicatorView()
                    if GTNet.shared.networkAvailable() {
                        self.showNotificationMessageView(message: "服务器连接中断")
                    } else {
                        self.showNotificationMessageView(message: "网络连接不可用")
                    }
                }, success: { json in
                    // 提取数据
                    let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                    let decoder = JSONDecoder()
                    if let dataModel = try? decoder.decode(GTPersonalRegisterModel.self, from: data!) {
                        if dataModel.code == -1 {
                            self.hideActivityIndicatorView()
                            self.showRegisterAlertController(message: dataModel.errorRes!)
                        } else {
                            UserDefaults.standard.set(account.text, forKey: UserDefaultKeys.AccountInfo.account)
                            UserDefaults.standard.set(password_2.text, forKey: UserDefaultKeys.AccountInfo.password)
                            self.refresh(refreshControl: nil)
                        }
                    } else {
                        self.hideActivityIndicatorView()
                        self.showNotificationMessageView(message: "服务器数据错误")
                    }
                })
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(registerAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func isPurnInt(string: String) -> Bool {
        let scan: Scanner = Scanner(string: string)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
     
    }
}

// UITableView
extension GTPersonalViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPersonalViewCell", for: indexPath) as! GTPersonalViewCell
        cell.selectionStyle = .none
        cell.nicknameLabel.text = ""
        cell.detailTxtLabel.text = ""
        cell.headImgView.image = UIImage()
        
        if indexPath.section == 0 {
            cell.nicknameLabel.text = self.dataModel?.nickName ?? cellInfo[indexPath.section][indexPath.row]
            cell.detailTxtLabel.text = self.dataModel?.profile ?? ""
            cell.accessoryType = .none
            cell.headImgView.sd_setImage(with: URL(string: dataModel?.headImgUrl ?? ""), placeholderImage: UIImage(named: self.cellImg[0][0]))
            cell.nicknameLabel.textColor = self.dataModel == nil ? UIColor(hexString: "#157efb") : .black
            cell.textLabel?.text = ""
            cell.imageView?.image = UIImage()
        } else {
            cell.textLabel?.text = cellInfo[indexPath.section][indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: cellImg[indexPath.section][indexPath.row])
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) == nil {
                showActionSheetController()
            } else {
                self.personalInfoViewContrller = GTPersonalInfoViewController(dataModel: self.dataModel!)
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(self.personalInfoViewContrller!, animated: true)
                self.hidesBottomBarWhenPushed = false
            }
        } else if indexPath.section == 3 {
            if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) == nil {
                showActionSheetController()
            } else {
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(GTPersonalSettingViewController(viewController: self), animated: true)
                self.hidesBottomBarWhenPushed = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
                let shapeLayer = CAShapeLayer()
        let cornerRadius = 10
        cell.layer.mask = nil
        if sectionCount > 1 {
            switch indexPath.row {
            case 0:
                var bounds = cell.bounds
                bounds.origin.y += 1.0
                let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                cell.layer.mask = shapeLayer
            case sectionCount - 1:
                var bounds = cell.bounds
                bounds.size.height -= 1.0
                let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                cell.layer.mask = shapeLayer
            default:
                break
            }
        } else {
            let bezierPath = UIBezierPath(roundedRect: cell.bounds.insetBy(dx: 0.0,dy: 2.0), cornerRadius: CGFloat(cornerRadius))
            shapeLayer.path = bezierPath.cgPath
            cell.layer.mask = shapeLayer
        }
    }
}
