//
//  GTBookDetailViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/23.
//

import Foundation
import UIKit
import SDWebImage

class GTBookDetailTableViewController: GTTableViewController {
    
    private var finishedBtn: UIButton!
    
    private let dataModel: GTBookDataModel
    
    init(_ dataModel: GTBookDataModel) {
        self.dataModel = dataModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let navigationBar = self.navigationController?.navigationBar
//        let navigationBarAppearance = UINavigationBarAppearance()
//        navigationBarAppearance.shadowColor = .clear
//        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        self.view.backgroundColor = .white
        
        // NavigationBar
        self.setupNavigationBar()
        // tableView
        self.setupTableView()
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        finishedBtn = UIButton(type: .custom)
        finishedBtn.setTitle("完成", for: .normal)
        finishedBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        finishedBtn.setTitleColor(.systemBlue, for: .normal)
        finishedBtn.addTarget(self, action: #selector(finishedBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishedBtn)
    }
    
    // tableView
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.register(GTBookCoverTableViewCell.self, forCellReuseIdentifier: "GTBookCoverTableViewCell")
        tableView.register(GTBookIntroTableViewCell.self, forCellReuseIdentifier: "GTBookIntroTableViewCell")
        tableView.register(GTBookPublicationInfoTableViewCell.self, forCellReuseIdentifier: "GTBookPublicationInfoTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    // finishedBtn clicked
    @objc private func finishedBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // startReadBtn clicked
    @objc private func startReadBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            let fileName = self.dataModel.bookId
            if GTDiskCache.shared.getPDF(fileName) != nil {
                let userInfo = ["dataModel": self.dataModel]
                NotificationCenter.default.post(name: .GTDownloadBookFinished, object: self, userInfo: userInfo)
            } else {
                let vc = GTBaseNavigationViewController(rootViewController: GTDownloadPDFViewContrlloer(model: self.dataModel))
                self.present(vc, animated: true)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookCoverTableViewCell", for: indexPath) as! GTBookCoverTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.imgView.sd_setImage(with: URL(string: self.dataModel.downInfo.bookHeadUrl), placeholderImage: UIImage(named: "book_placeholder"))
            cell.titleLabel.text = self.dataModel.baseInfo.bookName
            cell.detailLabel.text = self.dataModel.baseInfo.authorName
            cell.cosmosView.rating = Double(self.dataModel.gradeInfo.averageScore)
            cell.cosmosView.text = String(self.dataModel.gradeInfo.remarkCount) + "个评分"
            cell.startReadBtn.addTarget(self, action: #selector(startReadBtnDidClicked(sender:)), for: .touchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookIntroTableViewCell", for: indexPath) as! GTBookIntroTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.detailLabel.text = self.dataModel.baseInfo.bookIntro
            if cell.isExpanded {
                cell.toggleExpanded()
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookPublicationInfoTableViewCell", for: indexPath) as! GTBookPublicationInfoTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            var data = GTBookPublicationInfoDataModel(lists: [])
            for i in 0..<6 {
                switch i {
                case 0:
                    data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: "", subtitleLabelText: ""))
                case 1:
                    let timeStr = self.dataModel.baseInfo.publishTime
                    if timeStr.count != 10 {
                        data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: "error年", subtitleLabelText: "error月error日"))
                    } else {
                        data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: timeStr[0...3] + "年", subtitleLabelText: timeStr[5...6] + "月" + timeStr[8...9] + "日"))
                    }
                case 2:
                    data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: String(self.dataModel.baseInfo.bookPage), subtitleLabelText: ""))
                case 3:
                    data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: self.dataModel.baseInfo.publishHouse, subtitleLabelText: ""))
                case 4:
                    data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: "", subtitleLabelText: ""))
                default:
                    data.lists.append(GTBookPublicationInfoDataModelItem(imgName: "", contentLabelText: String(format: "%.1f", self.dataModel.downInfo.fileSize), subtitleLabelText: ""))
                }
            }
            cell.dataModel = data
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? GTBookIntroTableViewCell {
            if !cell.isExpanded {
                cell.isExpanded = true
                tableView.reloadData()
            }
        }
    }
}
