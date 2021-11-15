//
//  GTSearchStoreViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/15.
//

import Foundation
import UIKit
import MJRefresh

// cell的button的最大宽度
var searStoreCollectViewCellBtnMaxWidth = 100.0

class GTSearchStoreViewController: GTBaseViewController {
    
    var searchController: UISearchController!
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "探寻知识"
        self.view.backgroundColor = .white
        
        // 搜索条
        self.setupSearchBar()
        // scrollView
        self.setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController?.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 搜索条
    private func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.loadViewIfNeeded()
        searchController.searchBar.placeholder = "搜索书店"
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
//        searchController.searchResultsUpdater = vc
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .black
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
    }
    
    // tableView
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.register(GTSearchStoreTableViewCell.self, forCellReuseIdentifier: "GTSearchStoreTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(120)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

// UISearchBar
extension GTSearchStoreViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.transition(with: self.tableView, duration: 0.3, options: .curveLinear, animations: {
            self.tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        }, completion: nil)
        return true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        UIView.transition(with: self.tableView, duration: 0.3, options: .curveLinear, animations: {
            self.tableView.contentInset = UIEdgeInsets.zero
        }, completion: nil)
    }
}

// UITableView
extension GTSearchStoreViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTSearchStoreTableViewCell", for: indexPath) as! GTSearchStoreTableViewCell
        cell.selectionStyle = .none
        cell.accessoryType = .none

        return cell
    }
}


