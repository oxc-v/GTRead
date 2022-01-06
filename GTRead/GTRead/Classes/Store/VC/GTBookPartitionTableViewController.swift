//
//  GTBookPartitionTableViewController.swift
//  GTRead
//
//  Created by Dev on 2021/12/26.
//

import Foundation
import UIKit

class GTBookPartitionTableViewController: GTTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.borderWidth = 0.3
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "浏览分区"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // TableView
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(GTPartitionTableViewCell.self, forCellReuseIdentifier: "GTPartitionTableViewCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GTBookTypeLists.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPartitionTableViewCell", for: indexPath) as! GTPartitionTableViewCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
        cell.accessoryType = .disclosureIndicator
        
        cell.imgView.image = UIImage(named: "bookType_" + String(indexPath.row))
        cell.titleLab.text = GTBookTypeLists[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        let vc = GTBookReadMoreCollectionViewController(title: GTBookTypeLists[indexPath.row], layout: layout)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
