//
//  GTAnalyseViewController.swift
//  GTRead
//
//  Created by Dev on 2021/9/22.
//

import UIKit
import MJRefresh

class GTAnalyseViewController: GTBaseViewController {
    
    var oneDayReadTimeView: GTReadTimeView!
    
    var thisReadTimeView: GTThisReadDataView!
    var thisReadLineView: GTThisReadDataView!
    var thisReadPageView: GTThisReadDataView!
    var thisReadConcentrationView: GTThisReadDataView!
    let thisTimeReadDataCellMargin = 32.0
    
    var thisReadSpeedView: GTReadSpeedView!
    var thisReadBehaviourView: GTReadBehaviourView!
    
    var dataModel: GTAnalyseDataModel?
    let viewCornerRadius = 16.0
    let kGTScreenWidth = UIScreen.main.bounds.width
    
    lazy var analyseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(hexString: "#f2f2f7")
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let header = MJRefreshNormalHeader()
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("释放更新", for: .pulling)
        header.setTitle("正在刷新...", for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh(refreshControl:)))
        analyseScrollView.mj_header = header
        self.view.addSubview(analyseScrollView)
        analyseScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(-72)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        oneDayReadTimeView = GTReadTimeView()
        self.analyseScrollView.addSubview(oneDayReadTimeView)
        oneDayReadTimeView.snp.makeConstraints { (make) in
            make.centerX.left.right.top.equalToSuperview()
            make.height.equalTo(600)
        }
        
        thisReadTimeView = GTThisReadDataView(titleTxt: "本次阅读时间", dataTxt: "0时0分", imgName: "this_time")
        thisReadTimeView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadTimeView)
        thisReadTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(oneDayReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadConcentrationView = GTThisReadDataView(titleTxt: "本次阅读专注度", dataTxt: "0%", imgName: "this_concentration")
        thisReadConcentrationView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadConcentrationView)
        thisReadConcentrationView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadTimeView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadLineView = GTThisReadDataView(titleTxt: "本次阅读行数", dataTxt: "0", imgName: "this_line")
        thisReadLineView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadLineView)
        thisReadLineView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadConcentrationView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadPageView = GTThisReadDataView(titleTxt: "本次阅读页数", dataTxt: "0", imgName: "this_page")
        thisReadPageView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadPageView)
        thisReadPageView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadLineView.snp.right).offset(thisTimeReadDataCellMargin)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 - 3.0 * thisTimeReadDataCellMargin) / 4.0)
            make.top.equalTo(thisReadTimeView.snp.top)
        }
        
        thisReadSpeedView = GTReadSpeedView()
        thisReadSpeedView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadSpeedView)
        thisReadSpeedView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.width.height.equalTo((kGTScreenWidth - 2.0 * 16 -  32) / 2.0)
            make.top.equalTo(thisReadTimeView.snp.bottom).offset(32)
        }
        
        thisReadBehaviourView = GTReadBehaviourView()
        thisReadBehaviourView.layer.cornerRadius = viewCornerRadius
        self.analyseScrollView.addSubview(thisReadBehaviourView)
        thisReadBehaviourView.snp.makeConstraints { (make) in
            make.left.equalTo(thisReadLineView.snp.left)
            make.width.height.equalTo(thisReadSpeedView.snp.width)
            make.top.equalTo(thisReadSpeedView.snp.top)
        }
        
        // 判断用户上次是否登录
        if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) != nil {
            self.loadAnalyseData()
        } else {
            self.showNotLoginAlertController("有身份的人才能查看阅读数据哟", handler: {action in
                NotificationCenter.default.post(name: .GTGoLogin, object: self)
                self.tabBarController?.selectedIndex = 2
            })
        }
        
        // 响应登录成功通知
        NotificationCenter.default.addObserver(self, selector: #selector(loadAnalyseData), name: .GTLoginEvent, object: nil)
        // 响应退出登录通知
        NotificationCenter.default.addObserver(self, selector: #selector(clearAnalyseData), name: .GTExitAccount, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.analyseScrollView.updateContentView()
    }
    
    // 清空分析数据----退出登录
    @objc func clearAnalyseData() {
        self.oneDayReadTimeView.clearData()
        self.thisReadTimeView.clearData()
        self.thisReadConcentrationView.clearData()
        self.thisReadLineView.clearData()
        self.thisReadPageView.clearData()
        self.thisReadSpeedView.clearData()
        self.thisReadBehaviourView.clearData()
    }
    
    // 加载本地缓存
    @objc func loadAnalyseData() {
        self.showActivityIndicatorView()
        if let obj: GTAnalyseDataModel = GTDiskCache.shared.getViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_analyse_view") {
            self.dataModel = obj
            self.updateWithData(model: self.dataModel!)
            self.hideActivityIndicatorView()
        } else {
            self.refresh(refreshControl: nil)
        }
    }
    
    // 下拉刷新操作
    @objc func refresh(refreshControl: UIRefreshControl?) {
        // 判断用户上次是否登录
        if UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) != nil {
            GTNet.shared.getAnalyseData(failure: {json in
                refreshControl?.endRefreshing()
                self.hideActivityIndicatorView()
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
            }) { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                self.dataModel = try? decoder.decode(GTAnalyseDataModel.self, from: data!)
                if self.dataModel == nil {
                    self.showNotificationMessageView(message: "服务器数据错误")
                } else if self.dataModel!.status.code == -1 {
                    self.updateWithData(model: self.dataModel!)
                } else {
                    self.updateWithData(model: self.dataModel!)
                    
                    // 对阅读数据进行缓存
                    GTDiskCache.shared.saveViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_analyse_view", value: self.dataModel)
                }
                
                self.hideActivityIndicatorView()
                refreshControl?.endRefreshing()
            }
        } else {
            self.hideActivityIndicatorView()
            refreshControl?.endRefreshing()
            self.showNotLoginAlertController("有身份的人才能查看阅读数据哟", handler: {action in
                NotificationCenter.default.post(name: .GTGoLogin, object: self)
                self.tabBarController?.selectedIndex = 2
            })
        }
    }
    
    // 更新数据
    func updateWithData(model: GTAnalyseDataModel) {
        self.oneDayReadTimeView.updateWithData(model: model)
        self.thisReadTimeView.updateWithData(text: String(model.thisTimeData?.hour ?? 0) + "时" + String(model.thisTimeData?.min ?? 0) + "分")
        self.thisReadConcentrationView.updateWithData(text: String(format: "%.2f", (model.thisTimeData?.focus ?? 0) * 100) + "%")
        self.thisReadLineView.updateWithData(text: String(model.thisTimeData?.rows ?? 0))
        self.thisReadPageView.updateWithData(text: String(model.thisTimeData?.pages ?? 0))
        self.thisReadSpeedView.updateWithData(model: model)
        self.thisReadBehaviourView.updateWithData(model: model)
    }
}

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}

extension GTAnalyseViewController: UIScrollViewDelegate {

}
