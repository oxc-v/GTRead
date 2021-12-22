//
//  GT.swift
//  GTRead
//
//  Created by Dev on 2021/11/2.
//

import UIKit
import Fuse

class GTShelfSearchResultsViewController: GTTableViewController {

    private var resultLabel: UILabel!
    private var dataModel: GTShelfDataModel?
    private var searchModel: GTShelfDataModel?
    private var resultModel = Array<(score: Double, book: GTBookDataModel)>()
    private let cellHeight: CGFloat = 150

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        tableView.register(GTCustomComplexTableViewCell.self, forCellReuseIdentifier: "GTCustomComplexTableViewCell")
        tableView.separatorStyle = .singleLine
        
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
        
        self.dataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTShelfDataModel)
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
        cell.imgView.sd_setImage(with: URL(string: self.searchModel?.lists?[indexPath.row].downInfo.bookHeadUrl ?? ""), placeholderImage: UIImage(named: "book_placeholder"))
        cell.titleLabel.text = self.searchModel?.lists?[indexPath.row].baseInfo.bookName
        cell.detailLabel.text = self.searchModel?.lists?[indexPath.row].baseInfo.authorName
        cell.button.isHidden = true

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileName = self.searchModel?.lists?[indexPath.row].bookId ?? ""
        if let url = GTDiskCache.shared.getPDF(fileName) {
            let vc = GTReadViewController(path: url, bookId: fileName)
            vc.hidesBottomBarWhenPushed = true;
            self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = GTBaseNavigationViewController(rootViewController: GTDownloadPDFViewContrlloer(model: (self.searchModel?.lists?[indexPath.row])!))
            self.presentingViewController?.navigationController?.present(vc, animated: true)
        }
    }
}

extension GTShelfSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.resultModel.removeAll()
        self.searchModel?.lists?.removeAll()
        self.searchModel?.count = 0
        if self.dataModel != nil && self.dataModel?.count != -1 {
            let fuse = Fuse()
            let pattern = fuse.createPattern(from: searchController.searchBar.text ?? "")

            self.dataModel?.lists!.forEach {
                if let result = fuse.search(pattern, in: $0.baseInfo.bookName) {
                    self.resultModel.append((result.score, $0))
                }
            }
        } else {
            self.resultLabel.isHidden = false
        }
        
        // 对搜索结果进行排序
        self.resultModel.sort(by: {return $0.score < $1.score})
        self.resultModel.forEach {
            self.searchModel?.lists?.append($0.book)
        }
        
        if self.searchModel?.lists?.count == 0 {
            self.resultLabel.isHidden = false
        } else {
            self.resultLabel.isHidden = true
        }

        self.tableView.reloadData()
    }
}
