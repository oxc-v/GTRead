//
//  GTCommentFiltrateTableViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/3.
//

import Foundation
import UIKit

// 保存选项值
var GTCommentFilterValue = 0

class GTCommentFiltrateTableViewController: GTTableViewController {
    
    private var cellInfo = [String]()
    
    init(cellInfo: Array<String>) {
        super.init(style: .plain)
        
        self.cellInfo = cellInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(GTCommentFiltrateTableViewCell.self, forCellReuseIdentifier: "GTCommentFiltrateTableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellInfo.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCommentFiltrateTableViewCell", for: indexPath) as! GTCommentFiltrateTableViewCell
        cell.selectionStyle = .none
        cell.titleLab.text = self.cellInfo[indexPath.row]
        if GTCommentFilterValue == indexPath.row {
            cell.imgView.image = UIImage(named: "filter")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != GTCommentFilterValue {
            GTCommentFilterValue = indexPath.row
            tableView.reloadData()
            
            // 发通知给其他视图控制器
            let userInfo = ["selectedIndex": indexPath.row, "selectedStr": self.cellInfo[indexPath.row]] as [String : Any]
            NotificationCenter.default.post(name: .GTCommentFilterValueChanged, object: self, userInfo: userInfo)
            
            self.dismiss(animated: true)
        }
    }
}
