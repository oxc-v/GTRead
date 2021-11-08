//
//  GTBookShelfViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/2/20.
//

import UIKit
import MJRefresh
import SnapKit

let cellName = "bookCollectioncell"

class GTBookShelfViewController: GTBaseViewController {
    lazy var bookCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(GTBookCollectionCell.self, forCellWithReuseIdentifier: cellName)
        
        return collectionView
    }()
    var leftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("编辑", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setTitle("删除", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }()
    var customTitleView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 44)
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = "让阅读成为一种习惯"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return view
    }()

    var searchController: UISearchController!
    
    var viewModel: GTBookShelfViewModel?
    
    var isEdit: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    func setupView() {
        self.view.resignFirstResponder()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = ""
        
        self.setupNavigation()
        
        let header = MJRefreshNormalHeader()
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("释放更新", for: .pulling)
        header.setTitle("正在刷新...", for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh(refreshControl:)))
        header.lastUpdatedTimeLabel?.isHidden = true
        header.stateLabel?.isHidden = true
        bookCollectionView.mj_header = header
        self.view.addSubview(bookCollectionView)
        bookCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(112)
            make.bottom.right.left.equalToSuperview()
        }
        
        self.viewModel = GTBookShelfViewModel(viewController: self,collectionView: self.bookCollectionView)
        self.viewModel?.seletedEvent = { [weak self] count in
            if count > 0 {
                self?.deleteButton.isHidden = false
            }else{
                self?.deleteButton.isHidden = true
            }
        }
        
        // 判断用户上次是否登录
        if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) != nil {
            self.loadData()
        } else {
            self.showNotLoginAlertController("有身份的人才能查看书架哟", handler: {action in
                NotificationCenter.default.post(name: .GTGoLogin, object: self)
                self.tabBarController?.selectedIndex = 2
            })
        }
        
        self.setupSearchBar()
        
        // 响应登录成功通知
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: .GTLoginEvent, object: nil)
    }
    
    // 加载数据
    @objc func loadData() {
        // 刷新书架
        self.showActivityIndicatorView()
        self.viewModel?.loadBookShelfData()
        self.setupSearchBar()
    }
    
    // 搜索条
    func setupSearchBar() {
        let vc = GTBookShelfSearchViewController(model: self.viewModel?.dataModel)
        searchController = UISearchController(searchResultsController: vc)
        searchController.loadViewIfNeeded()
        searchController.searchBar.placeholder = "搜索书架"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = vc
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
    }
    
    // 导航条
    func setupNavigation() {
        leftButton.addTarget(self, action: #selector(cancelEditEvent), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(StartEditEvent), for: .touchUpInside)
        let rightItems = [UIBarButtonItem(customView: rightButton),UIBarButtonItem(customView: deleteButton)]
        self.navigationItem.rightBarButtonItems = rightItems
        self.navigationItem.titleView = customTitleView
    }
    
    @objc func refresh(refreshControl: UIRefreshControl?) {
        // 判断用户上次是否登录
        if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) != nil {
            // 模拟请求
            self.viewModel?.createBookShelfData(refreshControl: refreshControl)
        } else {
            refreshControl?.endRefreshing()
            self.showNotLoginAlertController("有身份的人才能查看书架哟", handler: {action in
                NotificationCenter.default.post(name: .GTGoLogin, object: self)
                self.tabBarController?.selectedIndex = 2
            })
        }
    }
    
    @objc func StartEditEvent() {
        if isEdit {
            // 全选事件
            self.viewModel?.seletedAll()
            deleteButton.isHidden = false
        } else {
            isEdit = true
            leftButton.isHidden = false
            deleteButton.isHidden = false
            rightButton.setTitle("全选", for: .normal)
            // 进入编辑模式
            self.viewModel?.startEditing(isEditIng: true)
        }
    }
    
    @objc func cancelEditEvent() {
        isEdit = false
        leftButton.isHidden = true
        deleteButton.isHidden = true
        rightButton.setTitle("编辑", for: .normal)
        self.viewModel?.cancelEditing()
    }
    
    @objc func deleteEvent() {
        isEdit = false
        leftButton.isHidden = true
        deleteButton.isHidden = true
        rightButton.setTitle("编辑", for: .normal)
        self.viewModel?.deleteImages()
    }
}

extension GTBookShelfViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tabBarController?.tabBar.isHidden = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
