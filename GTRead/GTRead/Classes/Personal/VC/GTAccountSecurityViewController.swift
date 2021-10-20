//
//  GTAccountSecurityViewController.swift
//  GTRead
//
//  Created by Dev on 2021/10/20.
//

import UIKit

class GTAccountSecurityViewController: GTBaseViewController {

    var tableView: UITableView!
    var cellHeight = 70
    let cellInfo = [["修改密码"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "账号安全"
        self.view.backgroundColor = UIColor.white
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(GTAccountSecurityViewCell.self, forCellReuseIdentifier: "GTAccountSecurityViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    // 修改密码对话框
    func showChangePasswordAlertController(message: String = "") {
        let alertController = UIAlertController(title: "修改密码", message: message, preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "当前账户密码"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "新的密码"
            textField.isSecureTextEntry = true
            textField.keyboardType = .asciiCapableNumberPad;
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "确认新的密码"
            textField.isSecureTextEntry = true
            textField.keyboardType = .asciiCapableNumberPad;
        }
        let old_pwd = alertController.textFields![0]
        let new_pwd1 = alertController.textFields![1]
        let new_pwd2 = alertController.textFields![2]

        let changeAction = UIAlertAction(title: "修改", style: .default) { (action: UIAlertAction!) -> Void in
            if old_pwd.text != UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.password) {
                self.showChangePasswordAlertController(message: "当前密码输入错误")
            } else if new_pwd1 != new_pwd2 {
                self.showChangePasswordAlertController(message: "两次输入的新密码不一致")
            } else {
                
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

// UITableView
extension GTAccountSecurityViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTAccountSecurityViewCell", for: indexPath) as! GTAccountSecurityViewCell
        cell.selectionStyle = .none
        cell.txtLabel.text = cellInfo[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.showChangePasswordAlertController()
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
