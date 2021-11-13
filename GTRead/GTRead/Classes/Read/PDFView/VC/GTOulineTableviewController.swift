//
//  GTOulineTableviewController.swift
//  GTRead
//
//  Created by YangJie on 2021/4/21.
//

import UIKit
import PDFKit

class GTOulineTableviewController: UITableViewController {
    private var data = [PDFOutline]()
    var pdfOutlineRoot: PDFOutline? {
        didSet{
            for index in 0...(pdfOutlineRoot?.numberOfChildren)!-1 {
                let pdfOutline = pdfOutlineRoot?.child(at: index)
                pdfOutline?.isOpen = false
                data.append(pdfOutline!)
            }
            tableView.reloadData()
        }
    }
    var navigationTitle: String? {
        didSet {
            self.title = navigationTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(GTOulineTableViewCell.self, forCellReuseIdentifier: "GTOulineTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTOulineTableViewCell", for: indexPath) as! GTOulineTableViewCell
        
        let outline = data[indexPath.row];
        
        cell.textLab.text = outline.label
        
        if outline.numberOfChildren > 0 {
            cell.openBtn.isHidden = false
            
        } else {
            cell.openBtn.isHidden = true
        }
        
        cell.openBtnEvent = {[weak self] (sender)-> Void in
            let vc = GTOulineTableviewController(style: UITableView.Style.plain)
            vc.navigationTitle = outline.label
            vc.pdfOutlineRoot = outline
            self?.navigationController?.navigationBar.tintColor = UIColor(hexString: "#4b4b4b")
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ouline = data[indexPath.row]
        let userData: [String: PDFOutline] = ["ouline": ouline]
        
        // 跳转PDF
        NotificationCenter.default.post(name: .GTGoPDFViewForPage, object: self, userInfo: userData)
    }
}
