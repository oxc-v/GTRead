//
//  GTBookStoreSearchResultsViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit
import MJRefresh

class GTSearchResultsViewController: GTTableViewController {

    private var resultLabel: UILabel!
    private var loadingView: GTLoadingView!
    
    private var dataModel: GTSearchBookDataModel?

    private let cellHeight: CGFloat = 150
    private var searchOffset: Int = 0
    private var searchWord: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        
        // TableView
        self.setupTableView()
        // resultLabel
        self.setupResultLabel()
        
        // 注册加载搜索数据完毕通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleGetSearchDataNotification), name: .GTGetSearchDataFinished, object: self)
        // 注册搜索数据全部显示完毕通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchDataIsBottom), name: .GTSearchDataIsBottom, object: self)
    }
    
    // resultLabel
    private func setupResultLabel() {
        resultLabel = UILabel()
        resultLabel.textAlignment = .center
        resultLabel.textColor = UIColor(hexString: "#b4b4b4")
        resultLabel.text = "没有搜索结果"
        resultLabel.font = UIFont.systemFont(ofSize: 20)
        resultLabel.layer.zPosition = 100
        resultLabel.isHidden = true
        self.tableView.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    // TableView
    private func setupTableView() {
        let footer = MJRefreshAutoNormalFooter()
        footer.setTitle("释放加载", for: .pulling)
        footer.setTitle("正在加载...", for: .refreshing)
        footer.setTitle("已经到底啦～", for: .noMoreData)
        footer.setRefreshingTarget(self, refreshingAction: #selector(refreshSearchData(refreshControl:)))
        tableView.mj_footer = footer
        
        tableView.register(GTCustomComplexTableViewCell.self, forCellReuseIdentifier: "GTCustomComplexTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    // 添加书籍到书库
    @objc private func addBookToShelf(sender: UIButton) {
        
        let cell = sender.superview?.superview as! GTCustomComplexTableViewCell
        let accountInfoDataModel: GTAccountInfoDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        
        if accountInfoDataModel == nil {
            // 父类方法
            self.showLoginAlertController()
            
            sender.isHidden = false
            cell.loadingView.isHidden = true
            cell.loadingView.isAnimating = false
        } else {
            sender.clickedAnimation(withDuration: 0.2, completion: { _ in
                GTNet.shared.addBookToShelfFun(bookId: (self.dataModel?.lists?[sender.tag].bookId)!, failure: { error in
                    sender.isHidden = false
                    cell.loadingView.isHidden = true
                    cell.loadingView.isAnimating = false
                    if GTNet.shared.networkAvailable() {
                        self.showNotificationMessageView(message: "服务器连接中断")
                    } else {
                        self.showNotificationMessageView(message: "网络连接不可用")
                    }
                }, success: { json in
                    cell.loadingView.isHidden = true
                    cell.loadingView.isAnimating = false
                    
                    let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                    let decoder = JSONDecoder()
                    let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!)
                    if dataModel?.code == 1 {
                        // 提示添加书籍成功
                        self.showNotificationMessageView(message: "书籍添加成功")
                        // 发送添加书籍到书库的通知
                        NotificationCenter.default.post(name: .GTAddBookToShelf, object: self)
                    } else {
                        sender.isHidden = false
                        self.showNotificationMessageView(message: dataModel?.errorRes ?? "error")
                    }
                })
            })
        }
    }
    
    // 上拉刷新
    @objc private func refreshSearchData(refreshControl: UIRefreshControl) {
        self.getSearchData(self.searchWord)
    }
    
    // 获取搜索数据
    private func getSearchData(_ searchWord: String) {
        
        // 获取当前日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dayTime = dateFormatter.string(from: Date())

        GTNet.shared.searchBookInfoFun(words: searchWord, dayTime: dayTime, count: 10, offset: searchOffset, failure: { error in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
            
            // 发送数据加载完毕通知
            NotificationCenter.default.post(name: .GTGetSearchDataFinished, object: self)
            
        }, success: { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let model = try? decoder.decode(GTSearchBookDataModel.self, from: data!)
            if model == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            } else if model?.count != -1 {
                
                if self.dataModel != nil {
                    for item in model!.lists! {
                        self.dataModel?.lists?.append(item)
                    }
                    self.searchOffset += model!.lists!.count
                } else {
                    self.dataModel = model
                    self.searchOffset += self.dataModel!.lists!.count
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // 发送数据加载完毕通知
                NotificationCenter.default.post(name: .GTGetSearchDataFinished, object: self)
            } else {
                // 发送数据全部加载完毕通知
                NotificationCenter.default.post(name: .GTSearchDataIsBottom, object: self)
            }
        })
    }
    
    // 响应加载搜索数据完毕通知
    @objc private func handleGetSearchDataNotification() {
        self.hideActivityIndicatorView()
        self.tableView.mj_footer?.endRefreshing()
    }
    
    // 响应搜索数据全部加载完毕通知
    @objc private func handleSearchDataIsBottom() {
        self.hideActivityIndicatorView()
        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
    }
}

extension GTSearchResultsViewController {
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
        cell.cosmosView.rating = Double((self.dataModel?.lists?[indexPath.row].gradeInfo.averageScore)!)
        
        // 判断书籍是否已加入书库
        if self.dataModel != nil {
            let item = self.dataModel!.lists![indexPath.row]
            var isExistShelf = false
            if let shelfDataModel: GTShelfDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTShelfDataModel) {
                if shelfDataModel.count != -1 {
                    isExistShelf = (shelfDataModel.lists)!.contains {$0.bookId == item.bookId}
                }
            }
            cell.buttonClickedEvent = isExistShelf ? nil : addBookToShelf(sender:)
            cell.button.isHidden = isExistShelf
            cell.button.tag = indexPath.row
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc =  GTBaseNavigationViewController(rootViewController: GTBookDetailTableViewController(self.dataModel!.lists![indexPath.row]))
        self.present(vc, animated: true)
    }
}

extension GTSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        // 重置步长和数据
        self.searchOffset = 0
        self.dataModel = nil
        self.tableView.reloadData()
        
        let trimmedString = (searchController.searchBar.text ?? " ").trimmingCharacters(in: .whitespaces)
        if !trimmedString.isEmpty {
            self.searchWord = trimmedString
            self.showActivityIndicatorView()
            self.getSearchData(trimmedString)
        }
    }
}

private extension Notification.Name {
    
    // 加载搜索数据完毕
    static let GTGetSearchDataFinished = Notification.Name("GTGetSearchDataFinished")
    
    // 搜索词相关的数据已全部加载完毕
    static let GTSearchDataIsBottom = Notification.Name("GTSearchDataIsBottom")
    
}
