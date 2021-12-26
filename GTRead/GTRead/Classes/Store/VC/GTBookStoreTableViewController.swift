//
//  GTBookStoreViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/11.
//

import Foundation
import UIKit
import SDWebImage
import SideMenu

class GTBookStoreTableViewController: GTTableViewController {
    
    private var accountBtn: UIButton!
    
    private var accountInfoDataModel: GTAccountInfoDataModel?
    
    private let sectionHeaderHeight = 50.0
    private let cellInfo = ["", "排行榜", "类型"]
    private let partitionInfo = ["计算机与互联网", "教育", "经管理财", "科幻奇幻", "悬疑推理", "全部"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航条
        self.setupNavigationBar()
        // Tableview
        self.setupTableView()
        
        // 注册用户登录的通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginSuccessfulNotification), name: .GTLoginSuccessful, object: nil)
        // 注册账户信息修改的通知
        NotificationCenter.default.addObserver(self, selector: #selector(accountBtnReloadImg), name: .GTAccountInfoChanged, object: nil)
        // 注册退出登录的通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleExitAccountNotification), name: .GTExitAccount, object: nil)
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        let scale = 1 - 1 / 30.0 * (102 - height)
        if height < 100 {
            accountBtn.transform = CGAffineTransform.identity.scaledBy(x: scale < 0 ? 0 : scale, y: scale < 0 ? 0 : scale)
        } else {
            accountBtn.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }
    }
    
    // 导航条
    private func setupNavigationBar() {
        self.navigationItem.title = "书城"
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
        tableView.register(GTSubareaTableViewCell.self, forCellReuseIdentifier: "GTSubareaTableViewCell")
        tableView.register(GTAdTableViewCell.self, forCellReuseIdentifier: "GTAdTableViewCell")
        tableView.register(GTRankingListTableViewCell.self, forCellReuseIdentifier: "GTRankingListTableViewCell")
        tableView.register(GTBookTypeTableViewCell.self, forCellReuseIdentifier: "GTBookTypeTableViewCell")
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
    
    // 响应退出登录通知
    @objc private func handleExitAccountNotification() {
        self.accountBtnReloadImg()
    }
    
    // 响应打开登录视图通知
    @objc private func handleOpenLoginViewNotification() {
        if self.tabBarController?.selectedIndex == 2 {
            self.dismiss(animated: true)
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountLoginTableViewController(style: .grouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.72, heightFluid: 0.65), viewController: vc, animated: true, completion: nil)
        }
    }
    
    // 响应打开注册视图通知
    @objc private func handleOpenRegisterViewNotification() {
        if self.tabBarController?.selectedIndex == 2 {
            self.dismiss(animated: true)
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountRegistTableViewController(style: .grouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.72, heightFluid: 0.65), viewController: vc, animated: true, completion: nil)
        }
    }
    
    // 响应打开修改密码视图通知
    @objc private func handleOpenUpdatePwdViewNotification() {
        if self.tabBarController?.selectedIndex == 2 {
            self.dismiss(animated: true)
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountUpdatePwdTableViewController(style: .grouped))
            self.customPresentViewController(self.getPresenter(widthFluid: 0.72, heightFluid: 0.65), viewController: vc, animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.cellInfo.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 6
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 60
            } else {
                return 390
            }
        case 1:
            return 490
        default:
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        default:
            return self.sectionHeaderHeight + 20
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: self.sectionHeaderHeight))
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.text = self.cellInfo[section]
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
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTSubareaTableViewCell", for: indexPath) as! GTSubareaTableViewCell
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets.zero
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTAdTableViewCell", for: indexPath) as! GTAdTableViewCell
                cell.selectionStyle = .none
                cell.viewController = self
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTRankingListTableViewCell", for: indexPath) as! GTRankingListTableViewCell
            cell.selectionStyle = .none
            cell.viewController = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookTypeTableViewCell", for: indexPath) as! GTBookTypeTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            cell.separatorInset = UIEdgeInsets.zero
            if indexPath.row == 5 {
                cell.imgView.image = UIImage(named: "bookType_all")
            } else {
                cell.imgView.image = UIImage(named: "bookType_" + String(indexPath.row))
            }
            cell.titleLab.text = self.partitionInfo[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let leftMenu = SideMenuNavigationController(rootViewController: GTBookPartitionTableViewController(style: .grouped))
            leftMenu.leftSide = true
            leftMenu.menuWidth = 320
            leftMenu.presentationStyle = .menuSlideIn
            self.present(leftMenu, animated: true)
        }
    }
}
