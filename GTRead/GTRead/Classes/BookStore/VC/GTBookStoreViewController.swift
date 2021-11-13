//
//  GTBookStoreViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/11.
//

import Foundation
import UIKit
import Glideshow

class GTBookStoreViewController: GTBaseViewController {
    
    private var searchButton: UIButton!
    private var slideBooksDataModel: GTBookStoreADBookDataModel?
    private var glideshowView: Glideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named: "searchBookStore"), for: .normal)
        searchButton.backgroundColor = .clear
//        searchButton.addTarget(self, action: #selector(eyeButtonDidClicked), for: .touchUpInside)
        
        glideshowView = Glideshow()
        glideshowView.items = []
        glideshowView.delegate = self
        glideshowView.isCircular = true
        glideshowView.placeHolderImage = UIImage(named: "book_placeholder")
        glideshowView.pageIndicatorPosition = .hidden
        glideshowView.interval = 2
        self.view.addSubview(glideshowView)
        glideshowView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
            make.top.equalTo(80)
        }
        
        // 导航条
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getSlideshowBooks()
    }
    
    // 导航条
    private func setupNavigationBar() {
        let rightItems = [UIBarButtonItem(customView: searchButton)]
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    // 轮播书籍数据
    func getSlideshowBooks() {
        self.showActivityIndicatorView()
        GTNet.shared.getBookStoreADBooks(failure: {json in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: {json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try? decoder.decode(GTBookStoreADBookDataModel.self, from: data!)
            if dataModel == nil {
                self.showNotificationMessageView(message: "服务器数据错误")
            } else {
                for item in (dataModel?.lists)! {
                    self.glideshowView.items?.append(GlideItem(caption: "", title: "", description: "", imageURL: item.adUrl))
                }
                self.slideBooksDataModel = dataModel
            }
            
            self.hideActivityIndicatorView()
        })
    }
    
}

extension GTBookStoreViewController: GlideshowProtocol {
    func glideshowDidSelecteRowAt(indexPath: IndexPath, _ glideshow: Glideshow) {
        print(indexPath)
    }
    
    func pageDidChange(_ glideshow: Glideshow, didChangePageTo page: Int) {
        print(page)
    }
}
