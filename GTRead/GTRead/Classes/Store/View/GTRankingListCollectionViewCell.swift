//
//  GTRankingListCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/25.
//

import Foundation
import UIKit
import SDWebImage
import Alamofire

class GTRankingListCollectionViewCell: UICollectionViewCell {
    
    private var tableView: UITableView!
    var viewController: GTBookStoreTableViewController?
    var dataModel: GTShelfDataModel?
    
    private let headerHeight = 40.0
    var headerText: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GTRankingListBookTableViewCell.self, forCellReuseIdentifier: "GTRankingListBookTableViewCell")
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension GTRankingListCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: self.headerHeight))
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.text = self.headerText
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.width.left.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: self.headerHeight))
        let btn = UIButton()
        btn.setTitle("查看更多", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(.black, for: .normal)
        btn.setImage(UIImage(named: "right_>"), for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.contentHorizontalAlignment = .left
        footerView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.width.left.equalToSuperview()
        }
        
        return footerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTRankingListBookTableViewCell", for: indexPath) as! GTRankingListBookTableViewCell
        
        cell.selectionStyle = .none
        cell.numberLab.text = String(indexPath.row + 1)
        cell.authorNameLab.text = self.dataModel?.lists?[indexPath.row].baseInfo.authorName
        cell.bookNameLab.text = self.dataModel?.lists?[indexPath.row].baseInfo.bookName
        cell.imgView.sd_setImage(with: URL(string: self.dataModel?.lists?[indexPath.row].downInfo.bookHeadUrl ?? ""), placeholderImage: UIImage(named: "book_placeholder"))
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GTRankingListBookTableViewCell
        cell.clickedAnimation(withDuration: 0.1, completion: { _ in
            let vc = GTBaseNavigationViewController(rootViewController: GTBookDetailTableViewController((self.dataModel?.lists![indexPath.row])!))
            self.viewController?.present(vc, animated: true)
        })
    }
}
