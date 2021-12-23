//
//  GTAnalyseTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit
import SDWebImage

class GTAnalyseTableViewController: GTTableViewController {
    
    private var accountBtn: UIButton!
    
    private let sectionHeaderHeight = 50.0
    private var sectionText = [String]()
    
    private var accountInfoDataModel: GTAccountInfoDataModel? {
        didSet {
            if accountInfoDataModel == nil {
                // 父类方法
                self.showNotLoginView(true)
            } else {
                // 父类方法
                self.showNotLoginView(false)
                
                // 从服务器获取数据
                self.getDataFromServer()
            }
        }
    }

    private var dataModel: GTAnalyseDataModel? {
        didSet {
            if dataModel != nil {
                self.sectionText.append("")
                self.sectionText.append("阅读数据")
                if dataModel?.lists != nil || dataModel?.speedPoints != nil || dataModel?.scatterDiagram != nil {
                    self.sectionText.append("数据图表")
                }
            } else {
                self.sectionText.removeAll()
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
        
        // 注册用户登录的通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginSuccessfulNotification), name: .GTLoginSuccessful, object: nil)
        // 注册账户信息修改的通知
        NotificationCenter.default.addObserver(self, selector: #selector(accountBtnReloadImg), name: .GTAccountInfoChanged, object: nil)
        // 注册退出登录的通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleExitAccountNotification), name: .GTExitAccount, object: nil)
        // 注册退出阅读界面通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleExitReadViewNotification), name: .GTExitReadView, object: nil)
        // 注册打开登录视图通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenLoginViewNotification), name: .GTOpenLoginView, object: nil)
        // 注册打开注册视图通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenRegisterViewNotification), name: .GTOpenRegisterView, object: nil)
        // 注册打开修改密码视图通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenUpdatePwdViewNotification), name: .GTOpenUpdatePwdView, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.showAccountBtn(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.showAccountBtn(false)
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "分析"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        accountBtn = UIButton(type: .custom)
        accountBtn.sd_setImage(with: URL(string: self.accountInfoDataModel?.headImgUrl ?? ""), for: .normal, placeholderImage: UIImage(named: "head_placeholder"), options: SDWebImageOptions(rawValue: 0), context: nil)
        accountBtn.imageView?.contentMode = .scaleAspectFill
        accountBtn.imageView?.layer.cornerRadius = GTNavigationBarConst.ViewSizeForLargeState / 2.0
        accountBtn.addTarget(self, action: #selector(accountBtnDidClicked(sender:)), for: .touchUpInside)
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(accountBtn)
        accountBtn.snp.makeConstraints { make in
            make.right.equalTo(navigationBar.snp.right).offset(-GTNavigationBarConst.ViewRightMargin)
            make.bottom.equalTo(navigationBar.snp.bottom).offset(-10)
            make.height.width.equalTo(GTNavigationBarConst.ViewSizeForLargeState)
        }
    }
    
    // TableView
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(GTReadTargetTableViewCell.self, forCellReuseIdentifier: "GTReadTargetTableViewCell")
        tableView.register(GTReadDetailTableViewCell.self, forCellReuseIdentifier: "GTReadDetailTableViewCell")
        tableView.register(GTReadChartTableViewCell.self, forCellReuseIdentifier: "GTReadChartTableViewCell")
    }
    
    // accountBtn clicked
    @objc private func accountBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: { _ in
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountManagerTableViewController(style: .insetGrouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.64, heightFluid: 0.53), viewController: vc, animated: true, completion: nil)
        })
    }
    
    // accountBtn image change
    @objc private func accountBtnReloadImg() {
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        self.accountBtn.sd_setImage(with: URL(string: self.accountInfoDataModel?.headImgUrl ?? ""), for: .normal, placeholderImage: UIImage(named: "head_placeholder"), options: SDWebImageOptions(rawValue: 0), context: nil)
    }
    
    // accountBtn
    private func showAccountBtn(_ show: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.accountBtn.alpha = show ? 1 : 0
        }
    }
    
    // 响应登录成功通知
    @objc private func handleLoginSuccessfulNotification() {
        self.accountBtnReloadImg()
    }
    
    // 响应退出阅读界面通知
    @objc private func handleExitReadViewNotification() {
        self.getDataFromServer()
    }
    
    // 响应退出登录通知
    @objc private func handleExitAccountNotification() {
        self.dataModel = nil
        self.accountBtnReloadImg()
    }
    
    // 响应打开登录视图通知
    @objc private func handleOpenLoginViewNotification() {
        if self.tabBarController?.selectedIndex == 1 {
            self.dismiss(animated: true)
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountLoginTableViewController(style: .grouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.72, heightFluid: 0.65), viewController: vc, animated: true, completion: nil)
        }
    }
    
    // 响应打开注册视图通知
    @objc private func handleOpenRegisterViewNotification() {
        if self.tabBarController?.selectedIndex == 1 {
            self.dismiss(animated: true)
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountRegistTableViewController(style: .grouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.72, heightFluid: 0.65), viewController: vc, animated: true, completion: nil)
        }
    }
    
    // 响应打开修改密码视图通知
    @objc private func handleOpenUpdatePwdViewNotification() {
        if self.tabBarController?.selectedIndex == 1 {
            self.dismiss(animated: true)
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountUpdatePwdTableViewController(style: .grouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.72, heightFluid: 0.65), viewController: vc, animated: true, completion: nil)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        let scale = 1 - 1 / 30.0 * (102 - height)
        if height < 100 {
            accountBtn.transform = CGAffineTransform.identity.scaledBy(x: scale < 0 ? 0 : scale, y: scale < 0 ? 0 : scale)
        } else {
            accountBtn.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionText.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else {
            return self.sectionHeaderHeight + 20
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 450
        case 1:
            return 250
        default:
            return 380
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: self.sectionHeaderHeight))
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.text = self.sectionText[section]
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(GTViewMargin)
            make.width.lessThanOrEqualTo(200)
        }
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTReadTargetTableViewCell", for: indexPath) as! GTReadTargetTableViewCell
            cell.selectionStyle = .none
            cell.targetBtn.addTarget(self, action: #selector(targetBtnDidClicked), for: .touchUpInside)
            cell.goStoreBtn.addTarget(self, action: #selector(goStoreBtnDidClicked), for: .touchUpInside)
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTReadDetailTableViewCell", for: indexPath) as! GTReadDetailTableViewCell
            cell.selectionStyle = .none
            if self.dataModel != nil {
                cell.dataModel = self.dataModel!.thisTimeData
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTReadChartTableViewCell", for: indexPath) as! GTReadChartTableViewCell
            cell.selectionStyle = .none
            if self.dataModel != nil {
                cell.dataModel = self.dataModel!
            }
            return cell
        }
        
    }
}

extension GTAnalyseTableViewController {
    // 从服务器加载数据
    private func getDataFromServer() {
        self.showActivityIndicatorView()
        GTNet.shared.getAnalyseData(failure: {json in
            self.hideActivityIndicatorView()
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }) { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.dataModel = try? decoder.decode(GTAnalyseDataModel.self, from: data!)
            if self.dataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
            
            self.hideActivityIndicatorView()
        }
        
        // 获取每日阅读目标
        GTNet.shared.getReadTarget(failure: {json in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }) { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try? decoder.decode(GTReadTargetDataModel.self, from: data!)
            if dataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            } else if dataModel?.minute != 0 {
                // 保存阅读目标
                UserDefaults.standard.set(dataModel?.minute, forKey: GTUserDefaultKeys.EveryDayReadTarget.target)
                // 每日阅读目标改变通知
                NotificationCenter.default.post(name: .GTReadTargetChanged, object: self)
            }
        }
    }
    
    @objc func targetBtnDidClicked(sender: UIButton) {
        let popoverVC = GTMinutePickerViewController()
        let nav = GTBaseNavigationViewController(rootViewController: popoverVC)
        nav.modalPresentationStyle = .popover
        nav.preferredContentSize = CGSize(width: 220, height: 180)
        if let popoverController = nav.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: sender.frame.size.width / 2.0, y: sender.frame.size.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
        }
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func goStoreBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: {_ in
            self.tabBarController?.selectedIndex = 2
        })
    }
}
