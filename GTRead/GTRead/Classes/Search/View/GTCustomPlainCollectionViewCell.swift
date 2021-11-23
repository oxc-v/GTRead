//
//  GTCustomPlainCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/17.
//

import Foundation
import Foundation
import UIKit

class GTCustomPlainCollectionViewCell: UICollectionViewCell {
    
    var tableView: UITableView!
    var isHideLine = false
    var dataModel: GTCustomPlainTableViewCellDataModelItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.register(GTCustomPlainTableViewCell.self, forCellReuseIdentifier: "GTCustomPlainTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GTCustomPlainCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCustomPlainTableViewCell", for: indexPath) as! GTCustomPlainTableViewCell
        cell.imgView.image = UIImage(named: self.dataModel?.imgName ?? "search_word")
        cell.titleLabel.text = self.dataModel?.titleText ?? "error"
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if isHideLine {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            isHideLine = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GTCustomPlainTableViewCell
        let info: [String : String] = ["searchText" : cell.titleLabel.text ?? ""]
        cell.clickedAnimation(withDuration: 0.1, completion: {_ in
            // 发送激活UISearchController通知
            NotificationCenter.default.post(name: .GTActivateSearchController, object: self, userInfo: info)
        })
    }
}
