//
//  GTBookStoreSearchResultsViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTSearchResultsViewController: GTTableViewController {

    private var resultLabel: UILabel!
    private var dataModel: GTShelfDataModel?
    private var searchModel: GTShelfDataModel?
    private var resultModel = Array<(score: Double, book: GTBookDataModel)>()
    private let cellHeight: CGFloat = 150

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(GTCustomComplexTableViewCell.self, forCellReuseIdentifier: "GTCustomComplexTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataModel = GTCommonShelfDataModel
        self.searchModel = self.dataModel
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchModel?.lists?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCustomComplexTableViewCell", for: indexPath) as! GTCustomComplexTableViewCell
        
        cell.selectionStyle = .none
        cell.isCustomFrame = true
        cell.imgView.sd_setImage(with: URL(string: self.searchModel?.lists?[indexPath.row].bookHeadUrl ?? ""), placeholderImage: UIImage(named: "book_placeholder"))
        cell.titleLabel.text = self.searchModel?.lists?[indexPath.row].bookName
        cell.detailLabel.text = self.searchModel?.lists?[indexPath.row].authorName

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension GTSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       
    }
}
