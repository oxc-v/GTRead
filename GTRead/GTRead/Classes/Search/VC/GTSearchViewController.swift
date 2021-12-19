//
//  GTSearchStoreViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/15.
//

import Foundation
import UIKit
import MJRefresh
import SDWebImage
import Presentr

class GTSearchViewController: GTTableViewController {
    
    private let sectionMargin = 10.0
    private let sectionHeaderHeight = 50.0
    private var sectionText = ["探索更多", "时下热门"]
    private var sectionTextForSearching = [String]()
    
    private var accountBtn: UIButton!
    private var searchController: UISearchController!
    private var accountInfoDataModel: GTAccountInfoDataModel?
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
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        
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
        // 注册热门书籍点击事件
        NotificationCenter.default.addObserver(self, selector: #selector(openBookDetailView(notification:)), name: .GTExploreMoreBookCellCollectionViewCellClicked, object: nil)
        // 注册账户信息修改的通知
        NotificationCenter.default.addObserver(self, selector: #selector(accountBtnReloadImg), name: .GTAccountInfoChanged, object: nil)
        // 注册书本下载完毕通知
        NotificationCenter.default.addObserver(self, selector: #selector(downloadBookFinishedNotification(notification:)), name: .GTDownloadBookFinished, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showAccountBtn(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.showAccountBtn(false)
    }
    
    // searchBar
    private func setupSearchBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "搜索"
        self.navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        
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
        
        accountBtn = UIButton(type: .custom)
        accountBtn.sd_setImage(with: URL(string: self.accountInfoDataModel?.headImgUrl ?? ""), for: .normal, placeholderImage: UIImage(named: "head_placeholder"), options: SDWebImageOptions(rawValue: 0), context: nil)
        accountBtn.imageView?.contentMode = .scaleAspectFill
        accountBtn.imageView?.layer.cornerRadius = GTNavigationBarConst.ViewSizeForLargeState / 2.0
        accountBtn.addTarget(self, action: #selector(accountBtnDidClicked(sender:)), for: .touchUpInside)
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(accountBtn)
        accountBtn.snp.makeConstraints { make in
            make.right.equalTo(navigationBar.snp.right).offset(-GTNavigationBarConst.ViewRightMargin)
            make.bottom.equalTo(navigationBar.snp.bottom).offset(-GTNavigationBarConst.ViewBottomMarginForLargeState)
            make.height.width.equalTo(GTNavigationBarConst.ViewSizeForLargeState)
        }
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
    
    // accountBtn clicked
    @objc private func accountBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: { _ in
            let vc = GTBaseNavigationViewController(rootViewController: GTAccountManagerTableViewController(style: .insetGrouped))
            vc.definesPresentationContext = true
            self.customPresentViewController(self.getPresenter(widthFluid: 0.64, heightFluid: 0.53), viewController: vc, animated: true, completion: nil)
        })
    }
    
    // accountBtn
    private func showAccountBtn(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.accountBtn.alpha = show ? 1 : 0
        }
    }
    
    // accountBtn image change
    @objc private func accountBtnReloadImg() {
        self.accountInfoDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        self.accountBtn.sd_setImage(with: URL(string: self.accountInfoDataModel?.headImgUrl ?? ""), for: .normal, placeholderImage: UIImage(named: "head_placeholder"), options: SDWebImageOptions(rawValue: 0), context: nil)
    }
    
    // 激活UISearchController
    @objc private func activateSearchController(notification: Notification) {
        if let text = notification.userInfo?["searchText"] as? String {
            self.searchController.isActive = true
            self.searchController.searchBar.text = text
            self.appendSearchHistoryData(text: text)
        }
    }
    
    // 打开详情页
    @objc private func openBookDetailView(notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int {
            let vc =  GTBaseNavigationViewController(rootViewController: GTBookDetailTableViewController(self.exploreMoreDataModel!.lists![index]))
            self.present(vc, animated: true)
        }
    }
    
    // 书本下载完毕通知
    @objc private func downloadBookFinishedNotification(notification: Notification) {
        if self.tabBarController?.selectedIndex == 2 {
            if let dataModel = notification.userInfo?["dataModel"] as? GTBookDataModel {
                let fileName = dataModel.bookId
                if let url = GTDiskCache.shared.getPDF(fileName) {
                    self.dismiss(animated: true, completion: {
                        let vc = GTReadViewController(path: url, bookId: fileName)
                        vc.hidesBottomBarWhenPushed = true;
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                } else {
                    self.showNotificationMessageView(message: "文件打开失败")
                }
            }
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
        self.searchHistoryDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTSearchHistoryDataModel)
    }
    
    // 本地存储历史搜索记录
    private func saveSearchHistoryForDisk() {
        if self.searchHistoryDataModel != nil {
            GTUserDefault.shared.set(self.searchHistoryDataModel, forKey: GTUserDefaultKeys.GTSearchHistoryDataModel)
        }
    }
    
    // 清除历史搜索记录
    @objc private func clearSearchHistoryDataModel(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.2, completion: { _ in
            self.searchHistoryDataModel = nil
            UserDefaults.standard.removeObject(forKey: GTUserDefaultKeys.GTSearchHistoryDataModel)
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
                        cell.dataModel?.lists?.append(GTCustomComplexTableViewCellDataModelItem(imgUrl: item.downInfo.bookHeadUrl, titleText: item.baseInfo.bookName, detailText: item.baseInfo.authorName, buttonClickedEvent: isExistShelf ? nil : self.addBookToShelf(sender:)))
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        let scale = 1 - 1 / 30.0 * (154 - height)
        if height < 152 {
            accountBtn.transform = CGAffineTransform.identity.scaledBy(x: scale < 0 ? 0 : scale, y: scale < 0 ? 0 : scale)
        } else {
            accountBtn.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
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
