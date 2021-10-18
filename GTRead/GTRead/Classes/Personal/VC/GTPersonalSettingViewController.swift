//
//  GTPersonalSettingViewController.swift
//  GTRead
//
//  Created by Dev on 2021/10/12.
//

import UIKit

class GTPersonalSettingViewController: GTBaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var cellHeight = 70
    let cellInfo = [["退出登录"]]
    let viewController: GTPersonalViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "设置"
        self.view.backgroundColor = UIColor.white
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GTPersonalSettingViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    init(viewController: GTPersonalViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.cellHeight)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfo[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPersonalSettingViewCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = cellInfo[indexPath.section][indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let alertController = UIAlertController(title: "是否退出登录", message: "", preferredStyle: .alert)
            let loginAction = UIAlertAction(title: "退出登录", style: .destructive) {
                        (action: UIAlertAction!) -> Void in
                // 删除配置信息
                let userDefaults = UserDefaults.standard
                for key in userDefaults.dictionaryRepresentation() {
                    userDefaults.removeObject(forKey: key.key)
                }
                userDefaults.synchronize()
                self.viewController.resetPersonalInfo()
                self.navigationController?.popViewController(animated: true)
            }
            let registerAction = UIAlertAction(title: "切换账号", style: .default) {
                        (action: UIAlertAction!) -> Void in
                self.navigationController?.popViewController(animated: true)
                self.viewController.showLoginAlertController()
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default)
            alertController.addAction(loginAction)
            alertController.addAction(registerAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
