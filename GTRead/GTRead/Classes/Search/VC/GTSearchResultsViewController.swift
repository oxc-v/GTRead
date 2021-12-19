//
//  GTBookStoreSearchResultsViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTSearchResultsViewController: GTTableViewController {

    private var resultLabel: UILabel!
    private var dataModel: GTSearchBookDataModel?
    private var loadingView: GTLoadingView!
    
    private let cellHeight: CGFloat = 150
    private var searchOffset: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        tableView.register(GTCustomComplexTableViewCell.self, forCellReuseIdentifier: "GTCustomComplexTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        
        resultLabel = UILabel()
        resultLabel.textAlignment = .center
        resultLabel.textColor = UIColor(hexString: "#b4b4b4")
        resultLabel.text = "没有搜索结果"
        resultLabel.font = UIFont.systemFont(ofSize: 20)
        resultLabel.layer.zPosition = 100
        resultLabel.isHidden = true
        self.view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModel?.lists?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCustomComplexTableViewCell", for: indexPath) as! GTCustomComplexTableViewCell
        
        cell.selectionStyle = .none
        cell.isCustomFrame = true
        cell.imgView.sd_setImage(with: URL(string: self.dataModel?.lists?[indexPath.row].downInfo.bookHeadUrl ?? ""), placeholderImage: UIImage(named: "book_placeholder"))
        cell.titleLabel.text = self.dataModel?.lists?[indexPath.row].baseInfo.bookName
        cell.detailLabel.text = self.dataModel?.lists?[indexPath.row].baseInfo.authorName

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
    }
}

extension GTSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dayTime = dateFormatter.string(from: Date())
        let trimmedString = (searchController.searchBar.text ?? " ").trimmingCharacters(in: .whitespaces)
        if !trimmedString.isEmpty {
            self.showActivityIndicatorView()
            GTNet.shared.searchBookInfoFun(words: trimmedString, dayTime: dayTime, count: 10, offset: searchOffset, failure: { error in
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
                self.hideActivityIndicatorView()
            }, success: { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                let model = try? decoder.decode(GTSearchBookDataModel.self, from: data!)
                if model == nil {
                    self.showNotificationMessageView(message: "服务器数据错误")
                } else if model?.count != -1 {
                    self.dataModel = model
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                self.hideActivityIndicatorView()
            })
        }
    }
}
