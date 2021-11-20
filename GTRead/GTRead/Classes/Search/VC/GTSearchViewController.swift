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
    
    var searchController: UISearchController!
    var sectionMargin = 20.0
    var exploreMoreDataModel: GTExploreMoreDataModel?
    var hotSearchWordDataModel: GTHotSearchWordDataModel?
    var searchHistoryDataModel: GTSearchHistoryDataModel?
    var sectionText = ["探索更多", "时下热门"]
    var searchSectionText = [String]()
    var isBeginSearch = false {
        didSet {
            if isBeginSearch && self.searchHistoryDataModel != nil {
                self.searchSectionText.append("历史搜索")
            } else {
                self.searchSectionText.removeAll()
            }
        }
    }
    var dataLoadFinished: Int = 0 {
        didSet{
            if dataLoadFinished == 2 {
                dataLoadFinished = 0
                self.hideActivityIndicatorView()
                tableView.isHidden = false
                tableView.reloadData()
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
        
        // 搜索条
        self.setupSearchBar()
        // scrollView
        self.setupTableView()
        
        // 显示加载动画
        self.showActivityIndicatorView()
        // 加载热搜书籍
        self.getExploreMoreBookData()
        // 加载热搜词条
        self.getHotSearchWordData()
        
        // 注册激活UISearchController通知
        NotificationCenter.default.addObserver(self, selector: #selector(activateSearchController(notification:)), name: .GTActivateSearchController, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 从本地读取历史搜索记录
        if let obj: GTSearchHistoryDataModel = GTDiskCache.shared.getViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_search_history") {
            self.searchHistoryDataModel = obj
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 存储历史搜索记录
        if self.searchHistoryDataModel != nil {
            GTDiskCache.shared.saveViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_search_history", value: self.searchHistoryDataModel)
        }
    }
    
    // searchBar
    private func setupSearchBar() {
        
        let vc = GTSearchResultsViewController()
        searchController = UISearchController(searchResultsController: vc)
        searchController.loadViewIfNeeded()
        searchController.searchBar.placeholder = "搜索书店"
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
        tableView.sectionHeaderTopPadding = sectionMargin
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
    
    @objc private func activateSearchController(notification: Notification) {
        if let text = notification.userInfo?["searchText"] as? String {
            self.searchController.isActive = true
            self.searchController.searchBar.text = text
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isBeginSearch {
            return self.searchSectionText.count
        } else {
            return self.sectionText.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isBeginSearch {
            return self.searchSectionText[section]
        } else {
            return self.sectionText[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        var content = header.defaultContentConfiguration()
        content.text = self.isBeginSearch ? self.searchSectionText[section] : self.sectionText[section]
        content.textProperties.color = .black
        content.textProperties.font = UIFont.boldSystemFont(ofSize: 23)
        header.contentConfiguration = content
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isBeginSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTHotSearchWordCell", for: indexPath) as! GTHotSearchWordCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
//            cell.dataModel = nil
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
                cell.dataModel = self.exploreMoreDataModel
                if self.exploreMoreDataModel != nil {
                    cell.collectionView.reloadSections(IndexSet(integer: 0))
                }
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
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isBeginSearch = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
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
    }
}
