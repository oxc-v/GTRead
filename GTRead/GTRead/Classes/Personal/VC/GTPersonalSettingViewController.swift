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
        tableView.register(GTPersonalSettingViewCell.self, forCellReuseIdentifier: "GTPersonalSettingViewCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPersonalSettingViewCell", for: indexPath) as! GTPersonalSettingViewCell
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            cell.titleTxtLabel.text = cellInfo[indexPath.section][indexPath.row]
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            let loginAction = UIAlertAction(title: "退出登录", style: .destructive) {
                        (action: UIAlertAction!) -> Void in
                self.viewController.resetPersonalInfo()
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
