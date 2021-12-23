//
//  GTTabBarViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/2/20.
//

import UIKit
import SwiftUI

// 全局边距
let GTViewMargin = 40.0

class GTTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 15, vertical: -12)
        
        
        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = .black
        self.tabBar.itemPositioning = .centered
        self.tabBar.itemSpacing = 100
        
        self.createControllers()
    }
    
    func createControllers() {
        // 书库
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        let bookShelfNav = GTBaseNavigationViewController(rootViewController: GTShelfCollectionViewController(collectionViewLayout: layout))
        let bookShelfItem = UITabBarItem(title: "书库", image: UIImage(named: "shelf"), selectedImage: UIImage(named: "shelf"))
        bookShelfItem.imageInsets = UIEdgeInsets(top: 10, left: -65, bottom: -10, right: 0)
        bookShelfItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13)], for: .normal)
        bookShelfNav.tabBarItem = bookShelfItem
        
        // 分析
        let analyseNav = GTBaseNavigationViewController(rootViewController: GTAnalyseTableViewController(style: .grouped))
        let analyseItem = UITabBarItem(title: "分析", image: UIImage(named: "analyse"), selectedImage: UIImage(named: "analyse"))
        analyseItem.imageInsets = UIEdgeInsets(top: 10, left: -65, bottom: -10, right: 0)
        analyseItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13)], for: .normal)
        analyseNav.tabBarItem = analyseItem
        
        // 书城
        let storeNav = GTBaseNavigationViewController(rootViewController: GTBookStoreTableViewController(style: .grouped))
        let storeItem = UITabBarItem(title: "书城", image: UIImage(named: "store"), selectedImage: UIImage(named: "store"))
        storeItem.imageInsets = UIEdgeInsets(top: 10, left: -65, bottom: -10, right: 0)
        storeItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13)], for: .normal)
        storeNav.tabBarItem = storeItem
        
        // 搜索
        let searchNav = GTBaseNavigationViewController(rootViewController: GTSearchViewController())
        let searchItem = UITabBarItem(title: "搜索", image: UIImage(named: "search"), selectedImage: UIImage(named: "search"))
        searchItem.imageInsets = UIEdgeInsets(top: 10, left: -65, bottom: -10, right: 0)
        searchItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13)], for: .normal)
        searchNav.tabBarItem = searchItem
        
        self.viewControllers = [bookShelfNav, analyseNav, storeNav, searchNav]
    }
}

extension UITabBar {
    public override var traitCollection: UITraitCollection {
        var newTraitCollection: [UITraitCollection] = [super.traitCollection]
        // I need to force size class on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            newTraitCollection += [UITraitCollection(verticalSizeClass: .regular), UITraitCollection(horizontalSizeClass: .compact)]
        }
        return UITraitCollection(traitsFrom: newTraitCollection)
    }
}
