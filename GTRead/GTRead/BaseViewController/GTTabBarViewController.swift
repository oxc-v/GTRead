//
//  GTTabBarViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/2/20.
//

import UIKit
import SwiftUI

class GTTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = .black
        
        self.createControllers()
    }
    
    func createControllers() {
        // 书架
        let bookShelfNav = GTBaseNavigationViewController(rootViewController: GTBookShelfViewController())
        let bookShelfItem = UITabBarItem(title: "书架", image: UIImage(named: "shelf"), selectedImage: UIImage(named: "shelf"))
        bookShelfNav.tabBarItem = bookShelfItem
        
        // 书店
        let storeNav = GTBaseNavigationViewController(rootViewController: GTBookStoreViewController())
        let storeItem = UITabBarItem(title: "书店", image: UIImage(named: "store"), selectedImage: UIImage(named: "store"))
        storeNav.tabBarItem = storeItem
        
        // 搜索
        let searchNav = GTBaseNavigationViewController(rootViewController: GTSearchViewController())
        let searchItem = UITabBarItem(title: "搜索", image: UIImage(named: "search"), selectedImage: UIImage(named: "search"))
        searchNav.tabBarItem = searchItem
        
        // 分析
        let analyseNav = GTBaseNavigationViewController(rootViewController: GTAnalyseViewController())
        let analyseItem = UITabBarItem(title: "分析", image: UIImage(named: "analyse"), selectedImage: UIImage(named: "analyse"))
        analyseNav.tabBarItem = analyseItem
        
        // 个人
        let personalNav = GTBaseNavigationViewController(rootViewController: GTPersonalViewController())
        let personalItem = UITabBarItem(title: "个人", image: UIImage(named: "mine"), selectedImage: UIImage(named: "mine"))
        personalNav.tabBarItem = personalItem
        
        self.viewControllers = [bookShelfNav, storeNav, searchNav, analyseNav, personalNav]
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
