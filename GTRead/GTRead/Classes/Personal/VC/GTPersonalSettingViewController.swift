//
//  GTPersonalSettingViewController.swift
//  GTRead
//
//  Created by Dev on 2021/10/12.
//

import UIKit

class GTPersonalSettingViewController: GTBaseViewController {

    var tableView: UITableView!
    var cellHeight = 70
    let cellInfo = [["账号安全"], ["清除缓存"], ["退出登录"]]
    let viewController: GTPersonalViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "设置"
        self.view.backgroundColor = .white
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(GTPersonalSettingViewCell.self, forCellReuseIdentifier: "GTPersonalSettingViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(80)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    init(viewController: GTPersonalViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// UITableView
extension GTPersonalSettingViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPersonalSettingViewCell", for: indexPath) as! GTPersonalSettingViewCell
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.txtLabel.text = cellInfo[indexPath.section][indexPath.row]
        cell.detailTxtLabel.text = ""
        
        if indexPath.section == cellInfo.count - 1 {
            cell.accessoryType = .none
            cell.txtLabel.text = ""
            cell.titleTxtLabel.text = cellInfo[indexPath.section][indexPath.row]
        } else if indexPath.section == 1 {
            let cachesSize = String(format: "%.1f", GTDiskCache.shared.fileSizeOfCache())
            cell.detailTxtLabel.text = cachesSize + "M"
        } else {
            
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = GTAccountSecurityViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            let alertController = UIAlertController(title: "确定要清除缓存么？", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定清除", style: .destructive) {
                        (action: UIAlertAction!) -> Void in
                GTDiskCache.shared.clearCache()
                tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else if indexPath.section == cellInfo.count - 1 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            let loginAction = UIAlertAction(title: "退出登录", style: .destructive) {
                        (action: UIAlertAction!) -> Void in
                // 删除用户配置信息
                let userDefaults = UserDefaults.standard
                for key in userDefaults.dictionaryRepresentation() {
                    userDefaults.removeObject(forKey: key.key)
                }
                userDefaults.synchronize()
                
                self.navigationController?.popViewController(animated: true)
            }
            let registerAction = UIAlertAction(title: "切换账号", style: .default) {
                        (action: UIAlertAction!) -> Void in
                self.navigationController?.popViewController(animated: true)
                self.viewController.showLoginAlertController()
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default)
            alertController.addAction(registerAction)
            alertController.addAction(loginAction)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
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
