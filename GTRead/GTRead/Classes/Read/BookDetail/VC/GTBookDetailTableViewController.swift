//
//  GTBookDetailViewController.swift
//  GTRead
//
//  Created by Dev on 2021/11/23.
//

import Foundation
import UIKit
import SDWebImage
import ExpandableLabel
import Fuse

class GTBookDetailTableViewController: GTTableViewController {
    
    private var finishedBtn: UIButton!
    private var loadingView: GTLoadingView!
    
    let dataModel: GTBookDataModel
    var commentDataModel: GTBookCommentDataModel?
    let accountDataModel: GTAccountInfoDataModel?
    
    private var isCollapsedBookIntro = true
    
    init(_ dataModel: GTBookDataModel) {
        self.dataModel = dataModel
        self.accountDataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTAccountDataModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // TableView
        self.setupTableView()
        
        // 加载书本评论内容
        self.getBookCommentLists()
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: self.dataModel.baseInfo.bookName, style: .plain, target: nil, action: nil)
        
        finishedBtn = UIButton(type: .custom)
        finishedBtn.setTitle("完成", for: .normal)
        finishedBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        finishedBtn.setTitleColor(.systemBlue, for: .normal)
        finishedBtn.addTarget(self, action: #selector(finishedBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishedBtn)
        
        loadingView = GTLoadingView(colors: [UIColor(hexString: "#12c2e9"), UIColor(hexString: "#c471ed"), UIColor(hexString: "#f64f59")], lineWidth: 3)
        loadingView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadingView)
    }
    
    // tableView
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        tableView.register(GTBookCoverTableViewCell.self, forCellReuseIdentifier: "GTBookCoverTableViewCell")
        tableView.register(GTBookIntroTableViewCell.self, forCellReuseIdentifier: "GTBookIntroTableViewCell")
        tableView.register(GTBookPublicationInfoTableViewCell.self, forCellReuseIdentifier: "GTBookPublicationInfoTableViewCell")
        tableView.register(GTBookCommentTableViewCell.self, forCellReuseIdentifier: "GTBookCommentTableViewCell")
    }
    
    // finishedBtn clicked
    @objc private func finishedBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // startReadBtn clicked
    @objc private func startReadBtnDidClicked(sender: UIButton) {
        // 判断用户是否登录
        if self.accountDataModel != nil {
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
        } else {
            self.showLoginAlertController()
        }
    }
    
    // 获取评论内容列表--需用户登录后才能查看
    private func getBookCommentLists() {
        if self.accountDataModel != nil {
            self.loadingView.isAnimating = true
            
            GTNet.shared.getBookCommentLists(observer: self.accountDataModel!.userId, offset: 0, count: 10, bookId: self.dataModel.bookId, pattern: .hit, reverse: false, failure: { error in
                self.loadingView.isAnimating = false
                
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
            }, success: { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                if let dataModel = try? decoder.decode(GTBookCommentDataModel.self, from: data!) {
                    if dataModel.count != 0 {
                        self.commentDataModel = dataModel
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    self.showNotificationMessageView(message: "服务器数据错误")
                }
                
                self.loadingView.isAnimating = false
            })
        }
    }
    
    // addShelfBtn clicked
    @objc private func addShelfBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            if self.accountDataModel != nil {
                self.loadingView.isAnimating = true
                
                // 判断书籍是否已加入书库
                var isExit = false
                let shelfDataModel: GTShelfDataModel? = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTShelfDataModel)
                if shelfDataModel != nil && shelfDataModel!.count > 0 {
                    if (shelfDataModel!.lists)!.contains(where: {$0.bookId == self.dataModel.bookId}) {
                        self.showNotificationMessageView(message: "书籍已经在书架了哟")
                        self.loadingView.isAnimating = false
                        isExit = true
                    } else {
                        isExit = false
                    }
                }
                
                if !isExit {
                    GTNet.shared.addBookToShelfFun(bookId: self.dataModel.bookId, failure: { error in
                        self.loadingView.isAnimating = false
                        if GTNet.shared.networkAvailable() {
                            self.showNotificationMessageView(message: "服务器连接中断")
                        } else {
                            self.showNotificationMessageView(message: "网络连接不可用")
                        }
                    }, success: { json in
                        self.loadingView.isAnimating = false
                        
                        let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                        let decoder = JSONDecoder()
                        let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!)
                        if dataModel?.code == 1 {
                            // 提示添加书籍成功
                            self.showNotificationMessageView(message: "书籍添加成功了呢")
                            // 发送添加书籍到书库的通知
                            NotificationCenter.default.post(name: .GTAddBookToShelf, object: self)
                        } else {
                            self.showNotificationMessageView(message: dataModel?.errorRes ?? "error")
                        }
                    })
                }
            } else {
                self.showLoginAlertController()
            }
        })
    }
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            if self.accountDataModel != nil {
                let vc = GTCommentNavigationController(rootViewController: GTBookCommentEditTableViewController(style: .plain, userId: self.accountDataModel!.userId, bookId: self.dataModel.bookId, imgUrl: self.dataModel.downInfo.bookHeadUrl))
                self.present(vc, animated: true)
            } else {
                self.showLoginAlertController()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.commentDataModel != nil {
            return 4
        } else {
            return 3
        }
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
            cell.addShelfBtn.addTarget(self, action: #selector(addShelfBtnDidClicked(sender:)), for: .touchUpInside)
            cell.editCommentBtn.addTarget(self, action: #selector(editCommentBtnDidClicked(sender:)), for: .touchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookIntroTableViewCell", for: indexPath) as! GTBookIntroTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.detailLabel.delegate = self
            cell.layoutIfNeeded()
            cell.detailLabel.text = self.dataModel.baseInfo.bookIntro
            cell.detailLabel.collapsed = self.isCollapsedBookIntro
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookPublicationInfoTableViewCell", for: indexPath) as! GTBookPublicationInfoTableViewCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.dataModel = self.dataModel
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GTBookCommentTableViewCell", for: indexPath) as! GTBookCommentTableViewCell
            cell.selectionStyle = .none
            cell.viewController = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! GTBookIntroTableViewCell
            cell.detailLabel.toucheLabel()
        }
    }
}

extension GTBookDetailTableViewController: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        self.tableView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
            self.isCollapsedBookIntro = false
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        self.tableView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        self.tableView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
            self.isCollapsedBookIntro = true
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        self.tableView.endUpdates()
    }
}
