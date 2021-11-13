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
        let bookNav = GTBaseNavigationViewController(rootViewController: GTBookShelfViewController())
        let bookItem = UITabBarItem(title: "书架", image: UIImage(named: "shelf"), selectedImage: UIImage(named: "shelf"))
        bookNav.tabBarItem = bookItem
        
        // 书店
        let bookStoreNav = GTBaseNavigationViewController(rootViewController: GTBookStoreViewController())
        let bookStoreItem = UITabBarItem(title: "书店", image: UIImage(named: "bookStore"), selectedImage: UIImage(named: "bookStore"))
        bookStoreNav.tabBarItem = bookStoreItem
        
        // 分析
        let analyseNav = GTBaseNavigationViewController(rootViewController: GTAnalyseViewController())
        let analyseItem = UITabBarItem(title: "分析", image: UIImage(named: "analyse"), selectedImage: UIImage(named: "analyse"))
        analyseNav.tabBarItem = analyseItem
        
        // 个人
        let personalNav = GTBaseNavigationViewController(rootViewController: GTPersonalViewController())
        let personalItem = UITabBarItem(title: "个人", image: UIImage(named: "mine"), selectedImage: UIImage(named: "mine"))
        personalNav.tabBarItem = personalItem
        
        self.viewControllers = [bookNav, bookStoreNav, analyseNav, personalNav]
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
