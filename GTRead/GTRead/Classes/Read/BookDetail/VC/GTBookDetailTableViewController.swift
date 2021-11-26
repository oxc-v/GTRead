//
//  GTBookDetailViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/23.
//

import Foundation
import UIKit

class GTBookDetailTableViewController: GTTableViewController {
    
    private var exitBtn: UIButton!
    let text = "一朝一暮的光阴，如涓涓流水，去而不返。一聚一散的无常，如花开花谢，来去有时。 过往之事不可追，未来之事不可猜。 余生，便做一个豁达之人，让眼底有光，无惧黑暗。让心中有爱，不失温度。让灵魂有家，随处可栖。 有人说：眼睛，是心灵的窗户。"
    
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
        exitBtn = UIButton(type: .custom)
        exitBtn.setImage(UIImage(named: "exit_view"), for: .normal)
        exitBtn.addTarget(self, action: #selector(exitBtnDidClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: exitBtn)
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
    
    // 退出页面
    @objc private func exitBtnDidClicked() {
        self.dismiss(animated: true)
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

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookIntroTableViewCell", for: indexPath) as! GTBookIntroTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.detailLabel.text = text
            if cell.isExpanded {
                cell.toggleExpanded()
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookPublicationInfoTableViewCell", for: indexPath) as! GTBookPublicationInfoTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
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
