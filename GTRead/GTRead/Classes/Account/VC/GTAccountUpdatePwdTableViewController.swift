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
        updateBtn.setTitle("修改", for: .normal)
        updateBtn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .disabled)
        updateBtn.setTitleColor(.systemBlue, for: .normal)
        updateBtn.addTarget(self, action: #selector(cancelBtnDidClicked), for: .touchUpInside)
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
        subLabel.text = "登录您的账号"
        subLabel.font = UIFont.systemFont(ofSize: 17)
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
            cell.textfield.placeholder = "当前密码"
            cell.textfield.isSecureTextEntry = true
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            cell.textfield.placeholder = "新的密码"
            cell.textfield.isSecureTextEntry = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountLoginTableViewCell", for: indexPath) as! GTAccountLoginTableViewCell
            cell.selectionStyle = .none
            cell.textfield.placeholder = "确认新的密码"
            cell.textfield.isSecureTextEntry = true
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
