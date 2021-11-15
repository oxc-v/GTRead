//
//  GTBookStoreViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/11.
//

import Foundation
import UIKit
import Glideshow
import MJRefresh

class GTBookStoreViewController: GTBaseViewController {
    
    private var searchBtn: UIButton!
    private var selectedBtn: UIButton!
    private var slideBooksDataModel: GTBookStoreADBookDataModel?
    private var glideshowView: Glideshow!
    private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        searchBtn = UIButton(type: .custom)
        searchBtn.setImage(UIImage(named: "searchBookStore"), for: .normal)
        searchBtn.backgroundColor = .clear
        searchBtn.addTarget(self, action: #selector(selectedButtonDidClicked), for: .touchUpInside)
        
        selectedBtn = UIButton(type: .custom)
        selectedBtn.isSelected = true
        selectedBtn.setTitle("精选", for: .normal)
        selectedBtn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .normal)
        selectedBtn.setTitleColor(.black, for: .selected)
        selectedBtn.titleLabel?.textAlignment = .center
        selectedBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: selectedBtn.isSelected == true ? 23 : 17)
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        let header = MJRefreshNormalHeader()
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("释放更新", for: .pulling)
        header.setTitle("正在刷新...", for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh(refreshControl:)))
        scrollView.mj_header = header
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(80)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        glideshowView = Glideshow()
        glideshowView.items = [GlideItem(caption : "", title : "", description: "", backgroundImage: #imageLiteral(resourceName: "test3")), GlideItem(caption : "", title : "", description: "", backgroundImage: #imageLiteral(resourceName: "test2")), GlideItem(caption : "", title : "", description: "", backgroundImage: #imageLiteral(resourceName: "test1"))]
        glideshowView.delegate = self
        glideshowView.isCircular = true
        glideshowView.placeHolderImage = UIImage(named: "book_placeholder")
        glideshowView.pageIndicatorPosition = .hidden
        glideshowView.interval = 3
        self.scrollView.addSubview(glideshowView)
        glideshowView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(400)
            make.top.equalTo(10)
        }
        
        // 导航条
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollView.updateContentView()
    }
    
    // 导航条
    private func setupNavigationBar() {
        let leftItems = [UIBarButtonItem(customView: selectedBtn)]
        let rightItems = [UIBarButtonItem(customView: searchBtn)]
        self.navigationItem.leftBarButtonItems = leftItems
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    
    // 下拉刷新
    @objc private func refresh(refreshControl: UIRefreshControl?) {
        refreshControl?.endRefreshing()
    }
    
    // 搜索按钮点击事件
    @objc private func selectedButtonDidClicked() {
        self.tabBarController?.tabBar.isHidden = true
        let vc = GTSearchStoreViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 轮播书籍数据
//    func getSlideshowBooks() {
//        self.showActivityIndicatorView()
//        GTNet.shared.getBookStoreADBooks(failure: {json in
//            if GTNet.shared.networkAvailable() {
//                self.showNotificationMessageView(message: "服务器连接中断")
//            } else {
//                self.showNotificationMessageView(message: "网络连接不可用")
//            }
//        }, success: {json in
//            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
//            let decoder = JSONDecoder()
//            let dataModel = try? decoder.decode(GTBookStoreADBookDataModel.self, from: data!)
//            if dataModel == nil {
//                self.showNotificationMessageView(message: "服务器数据错误")
//            } else {
//                for item in (dataModel?.lists)! {
//                    self.glideshowView.items?.append(GlideItem(caption: "", title: "", description: "", imageURL: item.adUrl))
//                }
//                self.slideBooksDataModel = dataModel
//            }
//
//            self.hideActivityIndicatorView()
//        })
//    }
    
}

extension GTBookStoreViewController: GlideshowProtocol {
    func glideshowDidSelecteRowAt(indexPath: IndexPath, _ glideshow: Glideshow) {
        
    }
    
    func pageDidChange(_ glideshow: Glideshow, didChangePageTo page: Int) {
        
    }
}
