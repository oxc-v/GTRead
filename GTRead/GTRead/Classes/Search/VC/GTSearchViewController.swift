//
//  GTSearchStoreViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/15.
//

import Foundation
import UIKit
import MJRefresh

class GTSearchViewController: GTTableViewController {
    
    private let sectionMargin = 10.0
    private let sectionHeaderHeight = 50.0
    private var sectionText = ["探索更多", "时下热门"]
    private var sectionTextForSearching = [String]()
    
    private var searchController: UISearchController!
    private var exploreMoreDataModel: GTExploreMoreDataModel?
    private var hotSearchWordDataModel: GTHotSearchWordDataModel?
    private var searchHistoryDataModel: GTSearchHistoryDataModel? {
        didSet {
            if searchHistoryDataModel == nil {
                sectionTextForSearching.removeAll {$0 == "历史搜索"}
            }
            self.tableView.reloadData()
        }
    }
    private var isBeginSearch = false {
        didSet {
            if isBeginSearch && self.searchHistoryDataModel != nil {
                self.sectionTextForSearching.append("历史搜索")
            } else {
                self.sectionTextForSearching.removeAll()
            }
            self.tableView.reloadData()
        }
    }
    private var dataLoadFinished: Int = 0 {
        didSet{
            if dataLoadFinished == 2 {
                dataLoadFinished = 0
                self.hideActivityIndicatorView()
                tableView.isHidden = false
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                })
            } else if dataLoadFinished == 0 {
                self.hideActivityIndicatorView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.title = "搜索"
        self.navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        
        // 搜索条
        self.setupSearchBar()
        // scrollView
        self.setupTableView()
        
        // 显示加载动画
        self.showActivityIndicatorView()
        // 加载搜索页面数据
        self.getSearchViewData()
        // 读取本地历史搜索记录
        self.getSearchHistoryForDisk()
        
        // 注册激活UISearchController通知
        NotificationCenter.default.addObserver(self, selector: #selector(activateSearchController(notification:)), name: .GTActivateSearchController, object: nil)
        // 注册删除书库书籍的通知
        NotificationCenter.default.addObserver(self, selector: #selector(getSearchViewData), name: .GTDeleteBookToShelf, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // searchBar
    private func setupSearchBar() {
        
        let vc = GTSearchResultsViewController()
        searchController = UISearchController(searchResultsController: vc)
        searchController.loadViewIfNeeded()
        searchController.searchBar.placeholder = "搜索图书、作者"
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = vc
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .black
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
    }
    
    // tableView
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.isHidden = true
        tableView.backgroundColor = .white
        tableView.register(GTHotSearchWordCell.self, forCellReuseIdentifier: "GTHotSearchWordCell")
        tableView.register(GTExploreMoreBookCell.self, forCellReuseIdentifier: "GTExploreMoreBookCell")
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = self.sectionMargin
    }
    
    // 加载搜索页面数据
    @objc private func getSearchViewData() {
        self.getExploreMoreBookData()
        self.getHotSearchWordData()
    }
    
    // 加载热搜书籍
    private func getExploreMoreBookData() {
        GTNet.shared.getPopularSearchFun(count: 8, failure: { _ in
            self.dataLoadFinished = 0
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            self.dataLoadFinished += 1
            
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.exploreMoreDataModel = try? decoder.decode(GTExploreMoreDataModel.self, from: data!)
            if self.exploreMoreDataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    // 加载热搜词条
    private func getHotSearchWordData() {
        GTNet.shared.getMostlySearchFun(count: 10, failure: { _ in
            self.dataLoadFinished = 0
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            self.dataLoadFinished += 1
            
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.hotSearchWordDataModel = try? decoder.decode(GTHotSearchWordDataModel.self, from: data!)
            if self.hotSearchWordDataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    // 激活UISearchController
    @objc private func activateSearchController(notification: Notification) {
        if let text = notification.userInfo?["searchText"] as? String {
            self.searchController.isActive = true
            self.searchController.searchBar.text = text
            self.appendSearchHistoryData(text: text)
        }
    }
    
    // 追加历史搜索记录
    private func appendSearchHistoryData(text: String) {
        if self.searchHistoryDataModel == nil {
            self.searchHistoryDataModel = GTSearchHistoryDataModel(lists: [GTSearchHistoryDataModelItem(searchText: text)], count: 1)
        } else {
            let count = (self.searchHistoryDataModel?.lists?.count)!
            self.searchHistoryDataModel?.lists?.removeAll {$0.searchText == text}
            if count != (self.searchHistoryDataModel?.lists?.count)! {
                self.searchHistoryDataModel?.count -= 1
            }
            self.searchHistoryDataModel?.lists?.insert(GTSearchHistoryDataModelItem(searchText: text), at: 0)
            self.searchHistoryDataModel?.count += 1
        }
    }
    
    // 读取本地历史搜索记录
    private func getSearchHistoryForDisk() {
        if let obj: GTSearchHistoryDataModel = GTDiskCache.shared.getViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_search_history") {
            self.searchHistoryDataModel = obj
        }
    }
    
    // 本地存储历史搜索记录
    private func saveSearchHistoryForDisk() {
        if self.searchHistoryDataModel != nil {
            GTDiskCache.shared.saveViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_search_history", value: self.searchHistoryDataModel)
        }
    }
    
    // 清除历史搜索记录
    @objc private func clearSearchHistoryDataModel(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: { _ in
            self.searchHistoryDataModel = nil
            GTDiskCache.shared.delViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_search_history")
        })
    }
    
    // 添加书籍到书库
    @objc private func addBookToShelf(sender: UIButton) {
        let cell = sender.superview?.superview as! GTCustomComplexTableViewCell
        sender.clickedAnimation(withDuration: 0.2, completion: { _ in
            GTNet.shared.addBookToShelfFun(bookId: (self.exploreMoreDataModel?.lists?[sender.tag].bookId)!, failure: { error in
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
                    // 发送添加书籍到书库的通知
                    NotificationCenter.default.post(name: .GTAddBookToShelf, object: self)
                    // 提示添加书籍成功
                    self.showNotificationMessageView(message: "书籍添加成功")
                } else {
                    sender.isHidden = false
                    self.showNotificationMessageView(message: dataModel?.errorRes ?? "error")
                }
            })
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isBeginSearch {
            return self.sectionTextForSearching.count
        } else {
            return self.sectionText.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: self.sectionHeaderHeight))
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.text = self.isBeginSearch ? self.sectionTextForSearching[section] : self.sectionText[section]
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(GTViewMargin)
            make.width.lessThanOrEqualTo(200)
        }
        
        if isBeginSearch {
            let btn = UIButton()
            if self.searchHistoryDataModel != nil && section == 0 {
                btn.addTarget(self, action: #selector(clearSearchHistoryDataModel(sender:)), for: .touchUpInside)
            }
            btn.setTitle("清除", for: .normal)
            btn.backgroundColor = UIColor(hexString: "#f2f2f6")
            btn.layer.cornerRadius = 15
            btn.setTitleColor(.black, for: .normal)
            btn.titleLabel?.textAlignment = .center
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            headerView.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-10)
                make.width.equalTo(70)
                make.right.equalTo(-GTViewMargin)
                make.height.equalTo(32)
            }
        }
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isBeginSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTHotSearchWordCell", for: indexPath) as! GTHotSearchWordCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            if self.searchHistoryDataModel != nil {
                cell.dataModel = GTCustomPlainTableViewCellDataModel(lists: [GTCustomPlainTableViewCellDataModelItem(imgName: "", titleText: "")], count: 0)
                cell.dataModel?.lists?.removeAll()
                for item in (self.searchHistoryDataModel?.lists)! {
                    cell.dataModel?.lists?.append(GTCustomPlainTableViewCellDataModelItem(imgName: "search_word", titleText: item.searchText))
                }
                cell.dataModel?.count = (self.searchHistoryDataModel?.count)!
            }
            cell.collectionView.reloadSections(IndexSet(integer: 0))
            return cell
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTExploreMoreBookCell", for: indexPath) as! GTExploreMoreBookCell
                cell.accessoryType = .none
                cell.selectionStyle = .none
                if self.exploreMoreDataModel != nil {
                    cell.dataModel = GTCustomComplexTableViewCellDataModel(lists: [GTCustomComplexTableViewCellDataModelItem(imgUrl: "", titleText: "", detailText: "", buttonClickedEvent: nil)], count: 0)
                    cell.dataModel?.lists?.removeAll()
                    for item in (self.exploreMoreDataModel?.lists)! {
                        var isExistShelf = false
                        if GTCommonShelfDataModel != nil && GTCommonShelfDataModel?.count != -1 {
                            isExistShelf = (GTCommonShelfDataModel?.lists)!.contains {$0.bookId == item.bookId}
                        }
                        cell.dataModel?.lists?.append(GTCustomComplexTableViewCellDataModelItem(imgUrl: item.bookHeadUrl, titleText: item.bookName, detailText: item.authorName, buttonClickedEvent: isExistShelf ? nil : self.addBookToShelf(sender:)))
                    }
                    cell.dataModel?.count = (self.exploreMoreDataModel?.lists?.count)!
                }
                cell.collectionView.reloadSections(IndexSet(integer: 0))
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "GTHotSearchWordCell", for: indexPath) as! GTHotSearchWordCell
                cell.selectionStyle = .none
                cell.accessoryType = .none
                if self.hotSearchWordDataModel != nil {
                    cell.dataModel = GTCustomPlainTableViewCellDataModel(lists: [GTCustomPlainTableViewCellDataModelItem(imgName: "", titleText: "")], count: 0)
                    cell.dataModel?.lists?.removeAll()
                    for item in (self.hotSearchWordDataModel?.lists)! {
                        cell.dataModel?.lists?.append(GTCustomPlainTableViewCellDataModelItem(imgName: "search_word", titleText: item.bookName))
                    }
                    cell.dataModel?.count = (self.hotSearchWordDataModel?.lists?.count)!
                }
                cell.collectionView.reloadSections(IndexSet(integer: 0))
                return cell
            }
        }
    }
}

extension GTSearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        self.isBeginSearch = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isBeginSearch = false
        self.saveSearchHistoryForDisk()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            self.appendSearchHistoryData(text: text)
        }
    }
}
