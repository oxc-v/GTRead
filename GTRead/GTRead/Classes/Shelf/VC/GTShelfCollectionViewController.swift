//
//  GTBookShelfViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/2/20.
//

import UIKit
import MJRefresh
import SnapKit

class GTShelfCollectionViewController: GTCollectionViewController {
    
    private var cancelButton: UIButton!
    private var editButton: UIButton!
    private var deleteButton: UIButton!
    private var searchController: UISearchController!
    private var goLoginAndRegisterView: GTGoLoginAndRegisterView!
    
    private var dataModel: GTShelfDataModel? {
        didSet {
            if dataModel?.lists == nil || dataModel?.count == -1 {
                editButton.isEnabled = false
            } else {
                editButton.isEnabled = true
            }
        }
    }
    private var isSeletedAll: Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private var isEdit: Bool = false {
        didSet {
            if isEdit {
                cancelButton.isHidden = false
            } else {
                cancelButton.isHidden = true
            }
            // 更新书库界面
            self.collectionView.reloadData()
        }
    }
    private var selectedBooks = [GTBookDataModel]() {
        didSet {
            if selectedBooks.count == 0 {
                self.deleteButton.isHidden = true
            } else {
                self.deleteButton.isHidden = false
            }
        }
    }
    
    private let itemCountInRow = 4;
    private var itemWidth: CGFloat = 0
    private var itemHeight: CGFloat = 0
    private let itemMargin: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "书库"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        
        // 初始化变量
        self.initVariates()
        // 导航条
        self.setupNavigationBar()
        // CollectionView
        self.setupCollectionView()
        // 未登录视图
        self.setupGoLoginAndRegisterView()
        // LongGesture
        self.setupLongGestureRecognizerOnCollection()
        // 加载书架数据
        self.getShelfDataFromServer()
        
        // 注册添加书籍到书库的通知
        NotificationCenter.default.addObserver(self, selector: #selector(getShelfDataFromServer), name: .GTAddBookToShelf, object: nil)
        // 注册删除书库书籍的通知
        NotificationCenter.default.addObserver(self, selector: #selector(getShelfDataFromServer), name: .GTDeleteBookToShelf, object: nil)
        // 注册书本下载完毕通知
        NotificationCenter.default.addObserver(self, selector: #selector(tryOpenBook(notification:)), name: .GTDownloadBookFinished, object: nil)
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化变量
    private func initVariates() {
        itemWidth = floor((UIScreen.main.bounds.width - 2 * GTViewMargin - (CGFloat(itemCountInRow - 1) * itemMargin)) / CGFloat(itemCountInRow))
        itemHeight = floor(itemWidth * 1.60)
    }
    
    // 导航条
    private func setupNavigationBar() {
        cancelButton = UIButton(type: .custom)
        cancelButton.isHidden = true
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelEditEvent), for: .touchUpInside)
        
        editButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        editButton.setTitle("编辑", for: .normal)
        editButton.setTitleColor(UIColor.black, for: .normal)
        editButton.addTarget(self, action: #selector(editEvent), for: .touchUpInside)
        
        deleteButton = UIButton(type: .custom)
        deleteButton.isHidden = true
        deleteButton.setTitle("删除", for: .normal)
        deleteButton.setTitleColor(UIColor.red, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
        
        let rightItems = [UIBarButtonItem(customView: editButton),UIBarButtonItem(customView: deleteButton)]
        self.navigationItem.rightBarButtonItems = rightItems
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let vc = GTShelfSearchResultsViewController()
        searchController = UISearchController(searchResultsController: vc)
        searchController.loadViewIfNeeded()
        searchController.searchBar.placeholder = "搜索书库"
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = vc
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .black
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
    }
    
    // CollectionView
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(GTShelfCollectionViewCell.self, forCellWithReuseIdentifier: "GTShelfCollectionViewCell")
    }
    
    // 未登录视图
    private func setupGoLoginAndRegisterView() {
        goLoginAndRegisterView = GTGoLoginAndRegisterView()
        goLoginAndRegisterView.isHidden = true
        self.view.addSubview(goLoginAndRegisterView)
        goLoginAndRegisterView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(320)
        }
    }
    
    // LongGesture
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressedGesture)
    }
    
    // handle long gesture
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let p = gestureRecognizer.location(in: collectionView)
        if (collectionView?.indexPathForItem(at: p)) != nil {
            // 进入编辑状态
            self.editEvent()
        }
    }
    
    // 编辑事件
    @objc private func editEvent() {
        self.selectedBooks.removeAll()
        if self.isSeletedAll {
            // 点击全不选
            self.isSeletedAll = false
            editButton.setTitle("全选", for: .normal)
        } else if self.isEdit {
            // 点击全选
            for item in (self.dataModel?.lists)! {
                self.selectedBooks.append(item)
            }
            self.isSeletedAll = true
            editButton.setTitle("全不选", for: .normal)
        } else {
            // 点击编辑
            isEdit = true
            editButton.setTitle("全选", for: .normal)
        }
    }
    
    // 取消编辑事件
    @objc private func cancelEditEvent() {
        self.isEdit = false
        self.isSeletedAll = false
        self.deleteButton.isHidden = true
        editButton.setTitle("编辑", for: .normal)
    }
    
    // 删除书籍事件
    @objc private func deleteEvent() {
        // 进入取消编辑状态
        self.cancelEditEvent()
        // 请求删除书库书籍
        self.deleteShelfBooksFromServer()
    }
    
    // 请求删除书库书籍
    private func deleteShelfBooksFromServer() {
        self.showActivityIndicatorView()
        GTNet.shared.delShelfBook(books: self.selectedBooks, failure: {json in
            self.hideActivityIndicatorView()
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            self.hideActivityIndicatorView()
            
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try? decoder.decode(GTDelShelfBookModel.self, from: data!)
            
            if dataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            } else if dataModel?.FailBookIds == nil {
                self.showNotificationMessageView(message: "书籍删除成功")
                // 刷新书库界面
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                // 发送书籍删除的通知
                NotificationCenter.default.post(name: .GTDeleteBookToShelf, object: self)
            } else {
                self.showNotificationMessageView(message: "个别书籍删除失败")
            }
        })
    }
    
    // 从本地缓存加载书架数据
    private func getShelfDataFromDisk() {
        if let obj: GTShelfDataModel = GTDiskCache.shared.getViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_shelf_view") {
            self.dataModel = obj
            GTCommonShelfDataModel = dataModel
            self.collectionView.reloadData()
        }
    }
    
    // 从服务器拉取书架数据
    @objc private func getShelfDataFromServer() {
        self.showActivityIndicatorView()
        GTNet.shared.getShelfBook(failure: { json in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
            
            self.hideActivityIndicatorView()
            // 从本地缓存加载书架数据
            self.getShelfDataFromDisk()
        }, success: { json in
            self.hideActivityIndicatorView()
            
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try? decoder.decode(GTShelfDataModel.self, from: data!)
            if dataModel != nil {
                self.dataModel = dataModel
                // 更新全局书库数据对象
                GTCommonShelfDataModel = self.dataModel
                // 对书库数据进行本地缓存
                GTDiskCache.shared.saveViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_shelf_view", value: self.dataModel)
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
            }
            
            // 更新书库界面
            DispatchQueue.main .async {
                self.collectionView.reloadData()
            }
        })
    }
    
    // 尝试打开PDF
    @objc private func tryOpenBook(notification: Notification) {
        if self.tabBarController?.selectedIndex == 0 {
            if let dataModel = notification.userInfo?["dataModel"] as? GTBookDataModel {
                // 读取缓存
                let fileName = dataModel.bookId
                if let url = GTDiskCache.shared.getPDF(fileName) {
                    let vc = GTReadViewController(path: url, bookId: fileName)
                    vc.hidesBottomBarWhenPushed = true;
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showNotificationMessageView(message: "文件打开失败")
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataModel?.lists?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTShelfCollectionViewCell", for: indexPath) as! GTShelfCollectionViewCell

        let book = (self.dataModel?.lists?[indexPath.row])!
        cell.updateData(imgURL: book.bookHeadUrl)
        if self.isEdit {
            cell.startEdit()
            if self.isSeletedAll {
                cell.hiddenRightImageView(hidden: false)
            } else {
                cell.hiddenRightImageView(hidden: true)
            }
        } else {
            cell.endEdit()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEdit {
            let cell = collectionView.cellForItem(at: indexPath) as! GTShelfCollectionViewCell
            cell.hiddenRightImageView(hidden: cell.selectedStatu)
            if cell.selectedStatu {
                // 选中
                self.selectedBooks.append((self.dataModel?.lists?[indexPath.row])!)
            } else {
                // 取消选中
                let book = self.dataModel?.lists?[indexPath.row]
                self.selectedBooks.removeAll(where: {$0.bookId == book?.bookId})
            }
        } else {
            // 读取缓存
            let fileName = self.dataModel?.lists?[indexPath.row].bookId ?? ""
            if let url = GTDiskCache.shared.getPDF(fileName) {
                let vc = GTReadViewController(path: url, bookId: fileName)
                vc.hidesBottomBarWhenPushed = true;
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = GTDownloadPDFViewContrlloer(model: (self.dataModel?.lists?[indexPath.row])!)
                self.present(vc, animated: true)
            }
        }
    }
}

extension GTShelfCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
