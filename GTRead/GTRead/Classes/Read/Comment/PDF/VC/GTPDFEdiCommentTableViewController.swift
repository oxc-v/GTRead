//
//  GTPDFEdiCommentTableViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit
import SDWebImage

class GTPDFEdiCommentTableViewController: GTTableViewController {
    
    private var cancelBtn: UIButton!
    private var commitBtn: UIButton!
    private var titleView: UIView!
    private var imgView: GTShadowImageView!
    private var titleLab: UILabel!
    private var loadingView: GTLoadingView!
    
    private let textViewPlaceholder = "分享您的收获（或疑惑）给他人..."
    
    // 当数组该count为2时，commitBtn按钮才被启用
    private var commitBtnEnableFlag = [Int]() {
        didSet {
            if commitBtnEnableFlag.count == 2 {
                commitBtn.isEnabled = true
            } else {
                commitBtn.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupTableView()
    }
    
    private func setupNavigationBar() {
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelBtn.setTitleColor(.black, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        
        commitBtn = UIButton(type: .custom)
        commitBtn.setTitle("提交", for: .normal)
        commitBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        commitBtn.setTitleColor(.black, for: .normal)
        commitBtn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .disabled)
        commitBtn.addTarget(self, action: #selector(commitBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: commitBtn)
        commitBtn.isEnabled = false
        
        titleView = UIView()
        titleView.backgroundColor = .clear
        self.navigationController?.navigationBar.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
        }
        
        imgView = GTShadowImageView()
        imgView.imgView.contentMode = .scaleAspectFill
        imgView.imgView.clipsToBounds = true
        imgView.imgView.layer.cornerRadius = 5
        imgView.imgView.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "book_placeholder"))
        titleView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalTo(50)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        titleLab = UILabel()
        titleLab.text = "撰写评论"
        titleLab.font = UIFont.boldSystemFont(ofSize: 17)
        titleLab.textAlignment = .center
        titleView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(GTPDFEditCommentTableViewCell.self, forCellReuseIdentifier: "GTPDFEditCommentTableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTPDFEditCommentTableViewCell", for: indexPath) as! GTPDFEditCommentTableViewCell
        cell.selectionStyle = .none
        cell.commentTitleTextfield.delegate = self
        cell.commentContentTextView.delegate = self
        cell.commentContentTextView.text = self.textViewPlaceholder
        return cell
    }
    
    // 取消按钮点击事件
    @objc private func cancelBtnDidClicked(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // 提交按钮点击事件
    @objc private func commitBtnDidClicked(sender: UIButton) {
        
    }
}

extension GTPDFEdiCommentTableViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count != 0 {
            if !self.commitBtnEnableFlag.contains(1) {
                self.commitBtnEnableFlag.append(1)
            }
        } else {
            self.commitBtnEnableFlag.removeAll(where: {$0 == 1})
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = .lightGray
        }
    }
}

extension GTPDFEdiCommentTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text != nil {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            if newText.count != 0 {
                if !self.commitBtnEnableFlag.contains(0) {
                    self.commitBtnEnableFlag.append(0)
                }
            } else {
                self.commitBtnEnableFlag.removeAll(where: {$0 == 0})
            }
        }
        
        
        return true
    }
}
