//
//  GTBookStoreSearchResultsViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTSearchResultsViewController: GTTableViewController {

    var resultLabel: UILabel!
    var dataModel: GTShelfBookModel?
    var cellHeight: CGFloat = 150

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .green
        tableView.layer.borderWidth = 5
        tableView.register(GTCustomComplexTableViewCell.self, forCellReuseIdentifier: "GTCustomComplexTableViewCell")
        
        resultLabel = UILabel()
        resultLabel.textAlignment = .center
        resultLabel.textColor = UIColor(hexString: "#b4b4b4")
        resultLabel.text = "没有搜索结果"
        resultLabel.font = UIFont.systemFont(ofSize: 20)
        resultLabel.layer.zPosition = 100
        resultLabel.isHidden = true
        self.view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCustomComplexTableViewCell", for: indexPath) as! GTCustomComplexTableViewCell
        

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension GTSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       
    }
}
