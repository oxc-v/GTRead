//
//  GT.swift
//  GTRead
//
//  Created by Dev on 2021/11/2.
//

import UIKit
import Fuse

class GTBookShelfSearchViewController: GTBaseViewController {

    var tableView: UITableView!
    var resultLabel: UILabel!
    var dataModel: GTShelfBookModel?
    var searchModel: GTShelfBookModel?
    var resultModel = Array<(score: Double, book: GTShelfBookItemModel)>()
    var cellHeight: CGFloat = 200

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(GTBookShelfSearchViewCell.self, forCellReuseIdentifier: "GTBookShelfSearchViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.right.bottom.equalToSuperview()
        }
        
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
        
        // 响应退出登录通知
        NotificationCenter.default.addObserver(self, selector: #selector(clearData), name: .GTExitAccount, object: nil)
    }

    init(model: GTShelfBookModel?) {
        self.dataModel = model
        self.searchModel = model

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clearData() {
        self.dataModel = nil
    }
}

extension GTBookShelfSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.resultModel.removeAll()
        self.searchModel?.lists?.removeAll()
        self.searchModel?.count = 0
        if self.dataModel != nil && self.dataModel?.count != -1 {
            let fuse = Fuse()
            let pattern = fuse.createPattern(from: searchController.searchBar.text ?? "")

            self.dataModel?.lists!.forEach {
                if let result = fuse.search(pattern, in: $0.bookName) {
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

extension GTBookShelfSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchModel?.lists?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookShelfSearchViewCell", for: indexPath) as! GTBookShelfSearchViewCell
        
        cell.imgView.sd_setImage(with: URL(string: self.searchModel?.lists?[indexPath.row].bookHeadUrl ?? ""), placeholderImage: UIImage(named: "book_placeholder"))
        cell.titleLabel.text = self.searchModel?.lists?[indexPath.row].bookName
        cell.detailLabel.text = self.searchModel?.lists?[indexPath.row].authorName

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileName = self.searchModel?.lists?[indexPath.row].bookId ?? ""
        if let url = GTDiskCache.shared.getPDF(fileName) {
            let vc = GTReadViewController(path: url, bookId: fileName)
            vc.hidesBottomBarWhenPushed = true;
            self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = GTLoadPDFViewContrlloer(model: (self.searchModel?.lists?[indexPath.row])!)
            vc.hidesBottomBarWhenPushed = true;
            self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
