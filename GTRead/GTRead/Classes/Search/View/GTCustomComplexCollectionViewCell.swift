//
//  GTCustomViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTCustomComplexCollectionViewCell: UICollectionViewCell {
    
    var tableView: UITableView!
    var isHideLine = false
    var dataModel: GTCustomComplexTableViewCellDataModelItem?
    var cellIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.register(GTCustomComplexTableViewCell.self, forCellReuseIdentifier: "GTCustomComplexTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GTCustomComplexCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCustomComplexTableViewCell", for: indexPath) as! GTCustomComplexTableViewCell
        cell.imgView.sd_setImage(with: URL(string: dataModel?.imgUrl ?? ""), placeholderImage: UIImage(named: "book_placeholder"))
        cell.titleLabel.text = dataModel?.titleText ?? "error"
        cell.detailLabel.text = dataModel?.detailText ?? "error"
        cell.buttonClickedEvent = dataModel?.buttonClickedEvent
        cell.button.isHidden = dataModel?.buttonClickedEvent == nil ? true : false
        cell.button.tag = cellIndex
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 86, bottom: 0, right: 0)
        if isHideLine {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            isHideLine = false
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GTCustomComplexTableViewCell
        cell.clickedAnimation(withDuration: 0.1, completion: {_ in
        })
    }
}

