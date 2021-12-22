//
//  GTAccountSecurityTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit

class GTAccountSecurityTableViewController: GTTableViewController {
    
    private let cellInfo = [["修改密码"]]
    private let cellHeight = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "账户安全"
    }
    
    // TableView
    private func setupTableView() {
        tableView.register(GTAccountManagerCommonTableViewCell.self, forCellReuseIdentifier: "GTAccountManagerCommonTableViewCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfo.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfo[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountManagerCommonTableViewCell", for: indexPath) as! GTAccountManagerCommonTableViewCell
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.titleLabel.text = self.cellInfo[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // 发送打开修改密码弹窗通知
            NotificationCenter.default.post(name: .GTOpenUpdatePwdView, object: self)
        default:
            break
        }
    }
}
