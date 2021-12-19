//
//  GTAnalyseTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit

class GTAnalyseTableViewController: GTTableViewController {
    
    private let sectionHeaderHeight = 50.0
    private var sectionText = ["", "阅读数据"]

    private var dataModel: GTAnalyseDataModel? {
        didSet {
            if dataModel != nil {
                if dataModel?.lists != nil || dataModel?.speedPoints != nil || dataModel?.scatterDiagram != nil {
                    self.sectionText.append("数据图表")
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
        
        self.getDataFromServer()
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "分析"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
    }
    
    // TableView
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(GTReadTargetTableViewCell.self, forCellReuseIdentifier: "GTReadTargetTableViewCell")
        tableView.register(GTReadDetailTableViewCell.self, forCellReuseIdentifier: "GTReadDetailTableViewCell")
        tableView.register(GTReadChartTableViewCell.self, forCellReuseIdentifier: "GTReadChartTableViewCell")
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
            return 360
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
            self.tabBarController?.selectedIndex = 1
        })
    }
}
